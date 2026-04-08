import SwiftData
import SwiftUI
import XYSGCore

struct ShowDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let show: ShowRecord
    let namespace: Namespace.ID

    @State private var isPresentingEditor = false
    @State private var notesDraft = ""
    @State private var deletionError: String?
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                header
                metadataSection
                lineupSection
                notesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isPresentingEditor = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }

                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                ComposerView(showToEdit: show)
            }
            .presentationDetents([.large])
        }
        .onAppear {
            notesDraft = show.notes
        }
        .alert("删除这场演出？", isPresented: $showDeleteAlert) {
            Button("删除", role: .destructive) {
                deleteShow()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这会删除演出卡片，但不会删除厂牌、演员或场地实体。")
        }
        .alert("操作失败", isPresented: Binding(get: {
            deletionError != nil
        }, set: { newValue in
            if !newValue { deletionError = nil }
        })) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(deletionError ?? "")
        }
    }

    private var header: some View {
        LocalCoverArtworkView(
            storagePath: show.coverStoragePath,
            title: show.displayTitle,
            subtitle: show.brand?.displayName ?? show.venueDisplay,
            showsTextOverlay: false
        )
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 10) {
                Text(show.displayTitle)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)

                HStack(spacing: 10) {
                    pill(show.format.displayName, accent: AppTheme.sunOrange)
                    pill(show.myRole.displayName, accent: AppTheme.skyGlow)
                    pill(show.showType.displayName, accent: AppTheme.amethyst)
                }
            }
            .padding(22)
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(eyebrow: "Details", title: "演出信息")

            VStack(spacing: 12) {
                infoRow("时间", value: show.dateDisplay)
                infoRow("内容形式", value: show.format.displayName)
                infoRow("我的角色", value: show.myRole.displayName)
                infoRow("演出属性", value: show.showType.displayName)
                infoRow("厂牌", value: show.brand?.displayName ?? "未填写")
                infoRow("场地", value: show.venue?.displayName ?? "未填写")
                if let city = show.venue?.cityName, !city.isEmpty {
                    infoRow("城市", value: city)
                }
            }
            .glassSurface(tint: AppTheme.surfaceBright.opacity(0.18), padding: 18, cornerRadius: 28)
        }
    }

    private var lineupSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(eyebrow: "Lineup", title: "阵容")

            if show.performers.isEmpty {
                Text("还没有填写演员阵容。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .glassSurface(tint: AppTheme.surfaceBright.opacity(0.16), padding: 18, cornerRadius: 26)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(show.performers, id: \.id) { performer in
                        Text(performer.displayName)
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .glassSurface(tint: AppTheme.surfaceBright.opacity(0.16), padding: 18, cornerRadius: 26)
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(eyebrow: "Notes", title: "备注")

            TextEditor(text: $notesDraft)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 210)
                .padding(10)
                .foregroundStyle(AppTheme.textPrimary)
                .glassSurface(tint: AppTheme.surfaceBright.opacity(0.16), padding: 12, cornerRadius: 26)

            Button("保存备注") {
                show.notes = notesDraft
                do {
                    try modelContext.save()
                    Haptics.success()
                } catch {
                    Haptics.warning()
                    deletionError = error.localizedDescription
                }
            }
            .buttonStyle(GlowButtonStyle())
        }
    }

    private func infoRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .font(.subheadline)
    }

    private func pill(_ text: String, accent: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(accent.opacity(0.26), in: Capsule())
    }

    private func deleteShow() {
        do {
            try ShowRecordDeletionService().delete(show, in: modelContext)
            Haptics.success()
            dismiss()
        } catch {
            Haptics.warning()
            deletionError = error.localizedDescription
        }
    }
}
