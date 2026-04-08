import SwiftData
import SwiftUI

struct BrandSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\ProductionBrand.displayName)]) private var brands: [ProductionBrand]

    let selectedID: UUID?
    let onSelect: (ProductionBrand?) -> Void

    @State private var showEditor = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    SelectionRow(
                        title: "不选择厂牌",
                        subtitle: "这场演出先保留为空",
                        isSelected: selectedID == nil
                    ) {
                        Haptics.selection()
                        onSelect(nil)
                        dismiss()
                    }

                    ForEach(brands) { brand in
                        SelectionRow(
                            title: brand.displayName,
                            subtitle: brand.cityName ?? "厂牌实体",
                            isSelected: selectedID == brand.id
                        ) {
                            Haptics.selection()
                            onSelect(brand)
                            dismiss()
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("选择厂牌")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptics.softImpact()
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                BrandEditorSheet(brand: nil) { brand in
                    onSelect(brand)
                    dismiss()
                }
            }
        }
    }
}

struct VenueSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Venue.displayName)]) private var venues: [Venue]

    let selectedID: UUID?
    let onSelect: (Venue?) -> Void

    @State private var showEditor = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    SelectionRow(
                        title: "不选择场地",
                        subtitle: "这场演出先保留为空",
                        isSelected: selectedID == nil
                    ) {
                        Haptics.selection()
                        onSelect(nil)
                        dismiss()
                    }

                    ForEach(venues) { venue in
                        SelectionRow(
                            title: venue.displayName,
                            subtitle: [venue.cityName, venue.district].compactMap { $0 }.joined(separator: " · "),
                            isSelected: selectedID == venue.id
                        ) {
                            Haptics.selection()
                            onSelect(venue)
                            dismiss()
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("选择场地")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptics.softImpact()
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                VenueEditorSheet(venue: nil) { venue in
                    onSelect(venue)
                    dismiss()
                }
            }
        }
    }
}

struct PerformerSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Performer.displayName)]) private var performers: [Performer]

    let initiallySelected: [SelectedPerformer]
    let onDone: ([SelectedPerformer]) -> Void

    @State private var selectedIDs: Set<UUID> = []
    @State private var showEditor = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(performers) { performer in
                        SelectionRow(
                            title: performer.displayName,
                            subtitle: performer.stageName ?? "演员实体",
                            isSelected: selectedIDs.contains(performer.id)
                        ) {
                            Haptics.selection()
                            if selectedIDs.contains(performer.id) {
                                selectedIDs.remove(performer.id)
                            } else {
                                selectedIDs.insert(performer.id)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }

            VStack {
                Spacer()
                Button("完成选择") {
                    Haptics.success()
                    let selected = performers
                        .filter { selectedIDs.contains($0.id) }
                        .map { SelectedPerformer(id: $0.id, name: $0.displayName) }
                    onDone(selected)
                    dismiss()
                }
                .buttonStyle(GlowButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("选择演员")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptics.softImpact()
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            selectedIDs = Set(initiallySelected.map(\.id))
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                PerformerEditorSheet(performer: nil) { performer in
                    selectedIDs.insert(performer.id)
                }
            }
        }
    }
}

private struct SelectionRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? AppTheme.sunOrange : AppTheme.textSecondary)
            }
            .glassSurface(
                tint: isSelected ? AppTheme.sunOrange.opacity(0.18) : AppTheme.surfaceBright.opacity(0.16),
                padding: 18,
                cornerRadius: 24
            )
        }
        .buttonStyle(.plain)
    }
}

struct BrandLinkSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\ProductionBrand.displayName)]) private var brands: [ProductionBrand]

    let initiallySelectedIDs: Set<UUID>
    let onDone: ([UUID]) -> Void

    @State private var selectedIDs: Set<UUID> = []
    @State private var showEditor = false

    var body: some View {
        multiSelectionScaffold(title: "关联厂牌", showEditor: $showEditor) {
            ForEach(brands) { brand in
                SelectionRow(
                    title: brand.displayName,
                    subtitle: brand.cityName ?? "厂牌实体",
                    isSelected: selectedIDs.contains(brand.id)
                ) {
                    Haptics.selection()
                    toggle(brand.id)
                }
            }
        } doneAction: {
            Haptics.success()
            onDone(Array(selectedIDs))
            dismiss()
        }
        .onAppear {
            selectedIDs = initiallySelectedIDs
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                BrandEditorSheet(brand: nil) { brand in
                    selectedIDs.insert(brand.id)
                }
            }
        }
    }

    private func toggle(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
}

struct VenueLinkSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Venue.displayName)]) private var venues: [Venue]

    let initiallySelectedIDs: Set<UUID>
    let onDone: ([UUID]) -> Void

    @State private var selectedIDs: Set<UUID> = []
    @State private var showEditor = false

    var body: some View {
        multiSelectionScaffold(title: "关联场地", showEditor: $showEditor) {
            ForEach(venues) { venue in
                SelectionRow(
                    title: venue.displayName,
                    subtitle: [venue.cityName, venue.district].compactMap { $0 }.joined(separator: " · "),
                    isSelected: selectedIDs.contains(venue.id)
                ) {
                    Haptics.selection()
                    toggle(venue.id)
                }
            }
        } doneAction: {
            Haptics.success()
            onDone(Array(selectedIDs))
            dismiss()
        }
        .onAppear {
            selectedIDs = initiallySelectedIDs
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                VenueEditorSheet(venue: nil) { venue in
                    selectedIDs.insert(venue.id)
                }
            }
        }
    }

    private func toggle(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
}

struct PerformerLinkSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Performer.displayName)]) private var performers: [Performer]

    let initiallySelectedIDs: Set<UUID>
    let onDone: ([UUID]) -> Void

    @State private var selectedIDs: Set<UUID> = []
    @State private var showEditor = false

    var body: some View {
        multiSelectionScaffold(title: "关联演员", showEditor: $showEditor) {
            ForEach(performers) { performer in
                SelectionRow(
                    title: performer.displayName,
                    subtitle: performer.stageName ?? "演员实体",
                    isSelected: selectedIDs.contains(performer.id)
                ) {
                    Haptics.selection()
                    toggle(performer.id)
                }
            }
        } doneAction: {
            Haptics.success()
            onDone(Array(selectedIDs))
            dismiss()
        }
        .onAppear {
            selectedIDs = initiallySelectedIDs
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                PerformerEditorSheet(performer: nil) { performer in
                    selectedIDs.insert(performer.id)
                }
            }
        }
    }

    private func toggle(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
}

@MainActor
private func multiSelectionScaffold<Rows: View>(
    title: String,
    showEditor: Binding<Bool>,
    @ViewBuilder rows: () -> Rows,
    doneAction: @escaping @MainActor () -> Void
) -> some View {
    ZStack {
        AppTheme.backgroundGradient
            .ignoresSafeArea()

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                rows()
            }
            .padding(20)
            .padding(.bottom, 100)
        }

        VStack {
            Spacer()
            Button("完成选择") {
                doneAction()
            }
            .buttonStyle(GlowButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Haptics.softImpact()
                showEditor.wrappedValue = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
