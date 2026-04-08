import SwiftData
import SwiftUI
import UniformTypeIdentifiers
import XYSGCore

struct MoreView: View {
    private enum BackupAction {
        case exportArchive
        case importArchive
    }

    @Environment(\.modelContext) private var modelContext
    @State private var backupSnapshot: LocalBackupSnapshot?
    @State private var exportDocument: LocalBackupArchiveDocument?
    @State private var suggestedExportFileName = "xysg-backup.zip"
    @State private var showsExporter = false
    @State private var showsImporter = false
    @State private var showsRestoreConfirmation = false
    @State private var pendingImportURL: URL?
    @State private var feedbackMessage: String?
    @State private var activeError: String?
    @State private var isBusy = false
    @State private var activeAction: BackupAction?

    private let backupService = LocalBackupArchiveService()

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    hero
                    statusCard
                    actionsCard
                    notesCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(SettingsDestination.localBackup.title)
        .navigationBarTitleDisplayMode(.inline)
        .fileExporter(
            isPresented: $showsExporter,
            document: exportDocument,
            contentType: .zip,
            defaultFilename: suggestedExportFileName
        ) { result in
            switch result {
            case .success:
                Haptics.success()
                feedbackMessage = "zip 备份已导出。"
            case let .failure(error):
                activeError = error.localizedDescription
                Haptics.error()
            }
        }
        .fileImporter(
            isPresented: $showsImporter,
            allowedContentTypes: [.zip],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                pendingImportURL = urls.first
                showsRestoreConfirmation = pendingImportURL != nil
            case let .failure(error):
                activeError = error.localizedDescription
                Haptics.error()
            }
        }
        .confirmationDialog(
            "导入 zip 备份会覆盖当前本机卡片，确定继续吗？",
            isPresented: $showsRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button("导入并覆盖", role: .destructive) {
                Task {
                    await restore()
                }
            }

            Button("取消", role: .cancel) {}
        } message: {
            Text("恢复会先清空当前本地数据，再导入你选择的 zip 备份。")
        }
        .alert("完成", isPresented: Binding(
            get: { feedbackMessage != nil },
            set: { if !$0 { feedbackMessage = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(feedbackMessage ?? "")
        }
        .alert("出错了", isPresented: Binding(
            get: { activeError != nil },
            set: { if !$0 { activeError = nil } }
        )) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(activeError ?? "")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LOCAL BACKUP")
                .font(.caption.weight(.semibold))
                .tracking(2)
                .foregroundStyle(AppTheme.textSecondary)

            Text("把你的票根档案导出成 zip。")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("这一版改成本地 zip 备份和导入恢复，不依赖 iCloud capability，格式仍然带版本号。")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Archive Snapshot", title: "本次操作信息")

            if let backupSnapshot {
                VStack(alignment: .leading, spacing: 12) {
                    statusRow(title: "最近备份", value: AppTheme.detailFormatter.string(from: backupSnapshot.manifest.exportedAt))
                    statusRow(title: "App 版本", value: backupSnapshot.manifest.appVersion)
                    statusRow(
                        title: "内容数量",
                        value: "\(backupSnapshot.manifest.counts.shows) 场 / \(backupSnapshot.manifest.counts.performers) 位演员 / \(backupSnapshot.manifest.counts.brands) 个厂牌 / \(backupSnapshot.manifest.counts.venues) 个场地"
                    )
                    statusRow(title: "格式版本", value: "Schema \(backupSnapshot.manifest.schemaVersion)")
                }
            } else {
                Text("导出时会生成一个 zip 文件，你可以存到“文件”App、AirDrop，或者留着以后导入恢复。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .glassSurface(tint: AppTheme.surfaceBright.opacity(0.18), padding: 20, cornerRadius: 30)
    }

    private var actionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Actions", title: "备份与恢复")

            Button {
                Task {
                    await backup()
                }
            } label: {
                actionCard(
                    title: isBusy ? "正在生成..." : "导出 zip 备份",
                    subtitle: "把当前本机所有卡片、结构化实体和封面打包成一个 zip 文件",
                    iconName: "square.and.arrow.up",
                    accent: AppTheme.sunOrange,
                    isBusy: isBusy && activeAction == .exportArchive
                )
            }
            .buttonStyle(.plain)
            .disabled(isBusy)

            Button {
                showsImporter = true
            } label: {
                actionCard(
                    title: isBusy ? "正在导入..." : "导入 zip 备份",
                    subtitle: "选择一个本地 zip 备份并覆盖当前本机档案",
                    iconName: "square.and.arrow.down",
                    accent: AppTheme.skyGlow,
                    isBusy: isBusy && activeAction == .importArchive
                )
            }
            .buttonStyle(.plain)
            .disabled(isBusy)
        }
        .glassSurface(tint: AppTheme.surfaceBright.opacity(0.12), padding: 20, cornerRadius: 30)
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(eyebrow: "Compatibility", title: "恢复规则")

            Text("恢复前会先完整读取和校验 zip 里的备份包，再覆盖本地数据。备份内容按 JSON 分文件存放，未知字段会被忽略，缺失字段会回退到默认值。")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .glassSurface(tint: AppTheme.surfaceBright.opacity(0.12), padding: 20, cornerRadius: 30)
    }

    private func statusRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 72, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    private func actionCard(
        title: String,
        subtitle: String,
        iconName: String,
        accent: Color,
        isBusy: Bool
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accent.opacity(0.28),
                                        AppTheme.glassFillHighlight.opacity(0.8),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                Image(systemName: iconName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(accent)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            if isBusy {
                ProgressView()
                    .tint(AppTheme.textPrimary)
            } else {
                Image(systemName: "arrow.up.right")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(accent)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(accent.opacity(0.14))
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(AppTheme.glassStroke.opacity(0.7), lineWidth: 1)
                    }
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accent.opacity(0.18),
                                    AppTheme.glassFillHighlight.opacity(0.6),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
        )
    }

    private func backup() async {
        guard !isBusy else { return }
        activeAction = .exportArchive
        isBusy = true

        do {
            let document = try backupService.exportDocument(in: modelContext)
            exportDocument = document
            if let manifest = document.manifest {
                backupSnapshot = LocalBackupSnapshot(manifest: manifest)
                suggestedExportFileName = exportFileName(for: manifest)
            } else {
                suggestedExportFileName = "xysg-backup.zip"
            }
            showsExporter = true
        } catch {
            activeError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            Haptics.error()
        }

        isBusy = false
        activeAction = nil
    }

    private func restore() async {
        guard !isBusy else { return }
        guard let pendingImportURL else { return }
        activeAction = .importArchive
        isBusy = true

        do {
            let snapshot = try backupService.restore(from: pendingImportURL, in: modelContext)
            backupSnapshot = snapshot
            feedbackMessage = "已从 zip 备份恢复 \(snapshot.manifest.counts.shows) 场演出。"
            Haptics.success()
        } catch {
            activeError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            Haptics.error()
        }

        self.pendingImportURL = nil
        isBusy = false
        activeAction = nil
    }

    private func exportFileName(for manifest: BackupArchiveManifest) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return "xysg-backup-\(formatter.string(from: manifest.exportedAt)).zip"
    }
}
