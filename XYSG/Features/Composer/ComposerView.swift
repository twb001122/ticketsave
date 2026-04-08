import PhotosUI
import SwiftData
import SwiftUI
import XYSGCore

@MainActor
struct ComposerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let showToEdit: ShowRecord?

    @State private var draft: ComposerDraft
    @State private var coverSelection: PhotosPickerItem?
    @State private var saveError: String?
    @State private var isSaving = false
    @State private var showBrandSelector = false
    @State private var showVenueSelector = false
    @State private var showPerformerSelector = false

    init(showToEdit: ShowRecord? = nil) {
        self.showToEdit = showToEdit
        _draft = State(initialValue: showToEdit.map(ComposerDraft.from) ?? ComposerDraft())
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    coverSection
                    basicFieldsSection
                    pickersSection
                    lineupSection
                    notesSection

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(eyebrow: "Preview", title: "实时票卡预览")
                        TicketPreviewCard(draft: draft)
                    }

                    Button(isSaving ? "保存中..." : (showToEdit == nil ? "生成演出卡片" : "更新演出卡片")) {
                        Haptics.softImpact()
                        Task { await saveShow() }
                    }
                    .buttonStyle(GlowButtonStyle())
                    .disabled(isSaving)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 50)
            }
        }
        .navigationTitle(showToEdit == nil ? "Add Show" : "Edit Show")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("关闭") {
                    Haptics.selection()
                    dismiss()
                }
                .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .task(id: coverSelection) {
            guard let coverSelection else { return }
            do {
                if let data = try await coverSelection.loadTransferable(type: Data.self) {
                    draft.coverData = data
                    draft.coverFileExtension = coverSelection.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
                    Haptics.softImpact()
                }
            } catch {
                Haptics.warning()
                saveError = error.localizedDescription
            }
        }
        .sheet(isPresented: $showBrandSelector) {
            NavigationStack {
                BrandSelectionSheet(selectedID: draft.selectedBrandID) { brand in
                    draft.setBrand(id: brand?.id, name: brand?.displayName ?? "")
                }
            }
        }
        .sheet(isPresented: $showVenueSelector) {
            NavigationStack {
                VenueSelectionSheet(selectedID: draft.selectedVenueID) { venue in
                    draft.setVenue(
                        id: venue?.id,
                        name: venue?.displayName ?? "",
                        city: venue?.cityName ?? ""
                    )
                }
            }
        }
        .sheet(isPresented: $showPerformerSelector) {
            NavigationStack {
                PerformerSelectionSheet(initiallySelected: draft.selectedPerformers) { performers in
                    draft.selectedPerformers = performers
                }
            }
        }
        .alert("保存失败", isPresented: Binding(get: {
            saveError != nil
        }, set: { newValue in
            if !newValue { saveError = nil }
        })) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(saveError ?? "未知错误")
        }
    }

    @MainActor
    private var coverSection: some View {
        let previewDraft = draft

        return VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Cover", title: "上传或替换封面")

            PhotosPicker(selection: $coverSelection, matching: .images) {
                LocalCoverArtworkView(
                    data: previewDraft.coverData,
                    storagePath: previewDraft.coverStoragePath,
                    title: previewDraft.storedTitle,
                    subtitle: previewDraft.selectedBrandName
                )
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "photo.badge.plus")
                        .font(.headline.weight(.bold))
                        .padding(12)
                        .background(.ultraThinMaterial, in: Circle())
                        .padding(14)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var basicFieldsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Basics", title: "演出基本信息")

            glassField("演出标题", text: $draft.title)

            selectionBlock(
                title: "厂牌",
                value: draft.selectedBrandName.isEmpty ? "未选择厂牌" : draft.selectedBrandName,
                action: {
                    Haptics.selection()
                    showBrandSelector = true
                }
            )

            selectionBlock(
                title: "场地",
                value: draft.selectedVenueName.isEmpty ? "未选择场地" : [draft.selectedVenueName, draft.selectedVenueCity]
                    .filter { !$0.isEmpty }
                    .joined(separator: " · "),
                action: {
                    Haptics.selection()
                    showVenueSelector = true
                }
            )

            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: Binding(
                    get: { draft.date != nil },
                    set: { enabled in
                        Haptics.selection()
                        draft.date = enabled ? (draft.date ?? .now) : nil
                    }
                )) {
                    Text("记录具体时间")
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .tint(AppTheme.sunOrange)

                if draft.date != nil {
                    DatePicker(
                        "时间",
                        selection: Binding(
                            get: { draft.date ?? .now },
                            set: { draft.date = $0 }
                        )
                    )
                    .datePickerStyle(.compact)
                    .foregroundStyle(AppTheme.textPrimary)
                } else {
                    Text("这场演出可以先不填时间，之后再补。")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .glassSurface(tint: AppTheme.surfaceBright.opacity(0.15), padding: 16, cornerRadius: 24)
        }
    }

    private var pickersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Tags", title: "形式、角色、属性")

            pickerBlock(title: "内容形式", values: ShowFormat.allCases, selection: $draft.format)
            pickerBlock(title: "我的角色", values: ShowRole.allCases, selection: $draft.myRole)
            pickerBlock(title: "演出属性", values: ShowType.allCases, selection: $draft.showType)
        }
    }

    private var lineupSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Lineup", title: "阵容")

            Button {
                Haptics.selection()
                showPerformerSelector = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("选择演员")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(draft.selectedPerformers.isEmpty ? "暂未选择演员，可为空。" : "已选 \(draft.selectedPerformers.count) 位演员")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .glassSurface(tint: AppTheme.surfaceBright.opacity(0.16), padding: 18, cornerRadius: 24)
            }
            .buttonStyle(.plain)

            if !draft.selectedPerformers.isEmpty {
                FlowLayout(spacing: 10) {
                    ForEach(draft.selectedPerformers) { performer in
                        HStack(spacing: 8) {
                            Text(performer.name)
                                .font(.subheadline.weight(.medium))
                            Button {
                                Haptics.selection()
                                draft.removePerformer(id: performer.id)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption2.weight(.bold))
                            }
                        }
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Notes", title: "你的备注")

            TextEditor(text: $draft.notes)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 170)
                .foregroundStyle(AppTheme.textPrimary)
                .padding(8)
                .glassSurface(tint: AppTheme.surfaceBright.opacity(0.15), padding: 12, cornerRadius: 26)
        }
    }

    @ViewBuilder
    private func glassField(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .textInputAutocapitalization(.words)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .foregroundStyle(AppTheme.textPrimary)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @ViewBuilder
    private func selectionBlock(
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(value)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .glassSurface(tint: AppTheme.surfaceBright.opacity(0.16), padding: 18, cornerRadius: 24)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func pickerBlock<Value: Hashable & CaseIterable & RawRepresentable>(
        title: String,
        values: Value.AllCases,
        selection: Binding<Value>
    ) -> some View where Value.RawValue == String {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
                ForEach(Array(values), id: \.self) { value in
                    Button {
                        Haptics.selection()
                        selection.wrappedValue = value
                    } label: {
                        Text(displayName(for: value))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selection.wrappedValue == value ? Color.black.opacity(0.82) : AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(selection.wrappedValue == value ? AnyShapeStyle(AppTheme.heroGradient) : AnyShapeStyle(.ultraThinMaterial))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func displayName<Value: RawRepresentable>(for value: Value) -> String where Value.RawValue == String {
        switch value {
        case let format as ShowFormat:
            format.displayName
        case let role as ShowRole:
            role.displayName
        case let type as ShowType:
            type.displayName
        default:
            value.rawValue
        }
    }

    @MainActor
    private func saveShow() async {
        isSaving = true
        defer { isSaving = false }

        do {
            _ = try ShowUpsertService().save(draft: draft, editing: showToEdit, in: modelContext)
            Haptics.success()
            dismiss()
        } catch {
            Haptics.warning()
            saveError = error.localizedDescription
        }
    }
}

private struct FlowLayout<Content: View>: View {
    var spacing: CGFloat
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
