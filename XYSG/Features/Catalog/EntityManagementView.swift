import SwiftData
import SwiftUI

enum CatalogSection: String, CaseIterable, Identifiable {
    case performers
    case brands
    case venues

    var id: String { rawValue }

    var title: String {
        switch self {
        case .performers: "演员"
        case .brands: "俱乐部 / 厂牌"
        case .venues: "场地"
        }
    }

    var icon: String {
        switch self {
        case .performers: "person.2.fill"
        case .brands: "building.2.crop.circle"
        case .venues: "mappin.and.ellipse"
        }
    }
}

struct EntityManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Performer.displayName)]) private var performers: [Performer]
    @Query(sort: [SortDescriptor(\ProductionBrand.displayName)]) private var brands: [ProductionBrand]
    @Query(sort: [SortDescriptor(\Venue.displayName)]) private var venues: [Venue]

    @State private var selectedSection: CatalogSection = .performers
    @State private var performerEditorTarget: Performer?
    @State private var brandEditorTarget: ProductionBrand?
    @State private var venueEditorTarget: Venue?
    @State private var showsCreatePerformer = false
    @State private var showsCreateBrand = false
    @State private var showsCreateVenue = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            catalogTabs

            headerCard

            List {
                switch selectedSection {
                case .performers:
                    ForEach(performers, id: \.id) { performer in
                        PerformerManagementRow(performer: performer)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    Haptics.selection()
                                    performerEditorTarget = performer
                                } label: {
                                    Label("编辑", systemImage: "pencil")
                                }
                                .tint(.blue)

                                Button(role: .destructive) {
                                    Haptics.warning()
                                    deletePerformer(performer)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                case .brands:
                    ForEach(brands, id: \.id) { brand in
                        BrandManagementRow(brand: brand)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    Haptics.selection()
                                    brandEditorTarget = brand
                                } label: {
                                    Label("编辑", systemImage: "pencil")
                                }
                                .tint(.blue)

                                Button(role: .destructive) {
                                    Haptics.warning()
                                    deleteBrand(brand)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                case .venues:
                    ForEach(venues, id: \.id) { venue in
                        VenueManagementRow(venue: venue)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    Haptics.selection()
                                    venueEditorTarget = venue
                                } label: {
                                    Label("编辑", systemImage: "pencil")
                                }
                                .tint(.blue)

                                Button(role: .destructive) {
                                    Haptics.warning()
                                    deleteVenue(venue)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .sheet(item: $performerEditorTarget) { performer in
            NavigationStack {
                PerformerEditorSheet(performer: performer)
            }
        }
        .sheet(isPresented: $showsCreatePerformer) {
            NavigationStack {
                PerformerEditorSheet(performer: nil)
            }
        }
        .sheet(item: $brandEditorTarget) { brand in
            NavigationStack {
                BrandEditorSheet(brand: brand)
            }
        }
        .sheet(isPresented: $showsCreateBrand) {
            NavigationStack {
                BrandEditorSheet(brand: nil)
            }
        }
        .sheet(item: $venueEditorTarget) { venue in
            NavigationStack {
                VenueEditorSheet(venue: venue)
            }
        }
        .sheet(isPresented: $showsCreateVenue) {
            NavigationStack {
                VenueEditorSheet(venue: nil)
            }
        }
        .alert("操作失败", isPresented: Binding(get: { errorMessage != nil }, set: { newValue in
            if !newValue { errorMessage = nil }
        })) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var catalogTabs: some View {
        HStack(spacing: 10) {
            ForEach(CatalogSection.allCases) { section in
                Button {
                    guard selectedSection != section else { return }
                    Haptics.selection()
                    selectedSection = section
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: section.icon)
                            .font(.subheadline.weight(.semibold))
                        Text(section.title)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(selectedSection == section ? AppTheme.onAccentText : AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(selectedSection == section ? AnyShapeStyle(AppTheme.actionGradient) : AnyShapeStyle(.ultraThinMaterial))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(AppTheme.glassStroke.opacity(selectedSection == section ? 0.16 : 0.4))
                            }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("实体管理", systemImage: selectedSection.icon)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button {
                    presentCreateSheet()
                } label: {
                    Label("新增", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.sunOrange)
            }

            Text("在这里维护演员、厂牌和场地。演出录入页会直接复用这些实体。")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .glassSurface(tint: AppTheme.surfaceBright.opacity(0.18), padding: 20, cornerRadius: 28)
    }

    private func presentCreateSheet() {
        Haptics.softImpact()
        switch selectedSection {
        case .performers:
            showsCreatePerformer = true
        case .brands:
            showsCreateBrand = true
        case .venues:
            showsCreateVenue = true
        }
    }

    private func deletePerformer(_ performer: Performer) {
        do {
            try EntityCatalogService().deletePerformer(performer, in: modelContext)
            Haptics.success()
        } catch {
            Haptics.warning()
            errorMessage = error.localizedDescription
        }
    }

    private func deleteBrand(_ brand: ProductionBrand) {
        do {
            try EntityCatalogService().deleteBrand(brand, in: modelContext)
            Haptics.success()
        } catch {
            Haptics.warning()
            errorMessage = error.localizedDescription
        }
    }

    private func deleteVenue(_ venue: Venue) {
        do {
            try EntityCatalogService().deleteVenue(venue, in: modelContext)
            Haptics.success()
        } catch {
            Haptics.warning()
            errorMessage = error.localizedDescription
        }
    }
}

private struct PerformerManagementRow: View {
    let performer: Performer

    var body: some View {
        ManagementRowShell(
            title: performer.displayName,
            subtitle: performer.stageName ?? "演员实体",
            countText: "\(performer.shows.count) 场"
        )
    }
}

private struct BrandManagementRow: View {
    let brand: ProductionBrand

    var body: some View {
        ManagementRowShell(
            title: brand.displayName,
            subtitle: brand.cityName ?? "厂牌实体",
            countText: "\(brand.shows.count) 场"
        )
    }
}

private struct VenueManagementRow: View {
    let venue: Venue

    var body: some View {
        ManagementRowShell(
            title: venue.displayName,
            subtitle: [venue.cityName, venue.district].compactMap { $0 }.joined(separator: " · "),
            countText: "\(venue.shows.count) 场"
        )
    }
}

private struct ManagementRowShell: View {
    let title: String
    let subtitle: String
    let countText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title.isEmpty ? "未命名实体" : title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Text(countText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.sunOrange)
                }

                Spacer(minLength: 12)
            }
        }
        .glassSurface(tint: AppTheme.surfaceBright.opacity(0.16), padding: 18, cornerRadius: 24)
    }
}

struct PerformerEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\ProductionBrand.displayName)]) private var brands: [ProductionBrand]

    let performer: Performer?
    var onSaved: ((Performer) -> Void)? = nil

    @State private var name = ""
    @State private var stageName = ""
    @State private var selectedBrandIDs: Set<UUID> = []
    @State private var showsBrandSelector = false
    @State private var errorMessage: String?

    var body: some View {
        editorScaffold(title: performer == nil ? "新增演员" : "编辑演员") {
            glassField("演员名称", text: $name)
            glassField("艺名 / 备注", text: $stageName)
            relationSelectorCard(
                title: "关联厂牌",
                icon: "building.2.crop.circle",
                items: selectedBrands.map(\.displayName)
            ) {
                Haptics.softImpact()
                showsBrandSelector = true
            }
        } saveAction: {
            do {
                let service = EntityCatalogService()
                let saved: Performer
                if let performer {
                    try service.updatePerformer(
                        performer,
                        name: name,
                        stageName: stageName,
                        brandIDs: Array(selectedBrandIDs),
                        in: modelContext
                    )
                    saved = performer
                } else {
                    saved = try service.createPerformer(
                        name: name,
                        stageName: stageName,
                        brandIDs: Array(selectedBrandIDs),
                        in: modelContext
                    )
                }
                Haptics.success()
                onSaved?(saved)
                dismiss()
            } catch {
                Haptics.warning()
                errorMessage = error.localizedDescription
            }
        }
        .onAppear {
            name = performer?.displayName ?? ""
            stageName = performer?.stageName ?? ""
            selectedBrandIDs = Set(performer?.brands.map(\.id) ?? [])
        }
        .sheet(isPresented: $showsBrandSelector) {
            NavigationStack {
                BrandLinkSelectionSheet(initiallySelectedIDs: selectedBrandIDs) { ids in
                    selectedBrandIDs = Set(ids)
                }
            }
        }
        .alert("保存失败", isPresented: Binding(get: { errorMessage != nil }, set: { newValue in
            if !newValue { errorMessage = nil }
        })) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var selectedBrands: [ProductionBrand] {
        brands.filter { selectedBrandIDs.contains($0.id) }
    }
}

struct BrandEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Performer.displayName)]) private var performers: [Performer]
    @Query(sort: [SortDescriptor(\Venue.displayName)]) private var venues: [Venue]

    let brand: ProductionBrand?
    var onSaved: ((ProductionBrand) -> Void)? = nil

    @State private var name = ""
    @State private var cityName = ""
    @State private var selectedPerformerIDs: Set<UUID> = []
    @State private var selectedVenueIDs: Set<UUID> = []
    @State private var showsPerformerSelector = false
    @State private var showsVenueSelector = false
    @State private var errorMessage: String?

    var body: some View {
        editorScaffold(title: brand == nil ? "新增厂牌" : "编辑厂牌") {
            glassField("厂牌名称", text: $name)
            glassField("所属城市", text: $cityName)
            relationSelectorCard(
                title: "关联演员",
                icon: "person.2.fill",
                items: selectedPerformers.map(\.displayName)
            ) {
                Haptics.softImpact()
                showsPerformerSelector = true
            }
            relationSelectorCard(
                title: "关联场地",
                icon: "mappin.and.ellipse",
                items: selectedVenues.map(\.displayName)
            ) {
                Haptics.softImpact()
                showsVenueSelector = true
            }
        } saveAction: {
            do {
                let service = EntityCatalogService()
                let saved: ProductionBrand
                if let brand {
                    try service.updateBrand(
                        brand,
                        name: name,
                        cityName: cityName,
                        performerIDs: Array(selectedPerformerIDs),
                        venueIDs: Array(selectedVenueIDs),
                        in: modelContext
                    )
                    saved = brand
                } else {
                    saved = try service.createBrand(
                        name: name,
                        cityName: cityName,
                        performerIDs: Array(selectedPerformerIDs),
                        venueIDs: Array(selectedVenueIDs),
                        in: modelContext
                    )
                }
                Haptics.success()
                onSaved?(saved)
                dismiss()
            } catch {
                Haptics.warning()
                errorMessage = error.localizedDescription
            }
        }
        .onAppear {
            name = brand?.displayName ?? ""
            cityName = brand?.cityName ?? ""
            selectedPerformerIDs = Set(brand?.performers.map(\.id) ?? [])
            selectedVenueIDs = Set(brand?.venues.map(\.id) ?? [])
        }
        .sheet(isPresented: $showsPerformerSelector) {
            NavigationStack {
                PerformerLinkSelectionSheet(initiallySelectedIDs: selectedPerformerIDs) { ids in
                    selectedPerformerIDs = Set(ids)
                }
            }
        }
        .sheet(isPresented: $showsVenueSelector) {
            NavigationStack {
                VenueLinkSelectionSheet(initiallySelectedIDs: selectedVenueIDs) { ids in
                    selectedVenueIDs = Set(ids)
                }
            }
        }
        .alert("保存失败", isPresented: Binding(get: { errorMessage != nil }, set: { newValue in
            if !newValue { errorMessage = nil }
        })) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var selectedPerformers: [Performer] {
        performers.filter { selectedPerformerIDs.contains($0.id) }
    }

    private var selectedVenues: [Venue] {
        venues.filter { selectedVenueIDs.contains($0.id) }
    }
}

struct VenueEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Performer.displayName)]) private var performers: [Performer]

    let venue: Venue?
    var onSaved: ((Venue) -> Void)? = nil

    @State private var name = ""
    @State private var cityName = ""
    @State private var district = ""
    @State private var addressLine = ""
    @State private var selectedPerformerIDs: Set<UUID> = []
    @State private var showsPerformerSelector = false
    @State private var errorMessage: String?

    var body: some View {
        editorScaffold(title: venue == nil ? "新增场地" : "编辑场地") {
            glassField("场地名称", text: $name)
            glassField("城市", text: $cityName)
            glassField("区县 / 商圈", text: $district)
            glassField("详细地址", text: $addressLine)
            relationSelectorCard(
                title: "关联演员",
                icon: "person.2.fill",
                items: selectedPerformers.map(\.displayName)
            ) {
                Haptics.softImpact()
                showsPerformerSelector = true
            }
        } saveAction: {
            do {
                let service = EntityCatalogService()
                let saved: Venue
                if let venue {
                    try service.updateVenue(
                        venue,
                        name: name,
                        cityName: cityName,
                        addressLine: addressLine,
                        district: district,
                        performerIDs: Array(selectedPerformerIDs),
                        in: modelContext
                    )
                    saved = venue
                } else {
                    saved = try service.createVenue(
                        name: name,
                        cityName: cityName,
                        addressLine: addressLine,
                        district: district,
                        performerIDs: Array(selectedPerformerIDs),
                        in: modelContext
                    )
                }
                Haptics.success()
                onSaved?(saved)
                dismiss()
            } catch {
                Haptics.warning()
                errorMessage = error.localizedDescription
            }
        }
        .onAppear {
            name = venue?.displayName ?? ""
            cityName = venue?.cityName ?? ""
            district = venue?.district ?? ""
            addressLine = venue?.addressLine ?? ""
            selectedPerformerIDs = Set(venue?.performers.map(\.id) ?? [])
        }
        .sheet(isPresented: $showsPerformerSelector) {
            NavigationStack {
                PerformerLinkSelectionSheet(initiallySelectedIDs: selectedPerformerIDs) { ids in
                    selectedPerformerIDs = Set(ids)
                }
            }
        }
        .alert("保存失败", isPresented: Binding(get: { errorMessage != nil }, set: { newValue in
            if !newValue { errorMessage = nil }
        })) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var selectedPerformers: [Performer] {
        performers.filter { selectedPerformerIDs.contains($0.id) }
    }
}

@MainActor
private func editorScaffold<Content: View>(
    title: String,
    @ViewBuilder content: () -> Content,
    saveAction: @escaping @MainActor () -> Void
) -> some View {
    ZStack {
        AppTheme.backgroundGradient
            .ignoresSafeArea()

        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                content()

                Button("保存") {
                    saveAction()
                }
                .buttonStyle(GlowButtonStyle())
                .padding(.top, 10)
            }
            .padding(20)
        }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
}

private func glassField(_ placeholder: String, text: Binding<String>) -> some View {
    TextField(placeholder, text: text)
        .textInputAutocapitalization(.words)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .foregroundStyle(AppTheme.textPrimary)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
}

@MainActor
private func relationSelectorCard(
    title: String,
    icon: String,
    items: [String],
    action: @escaping @MainActor () -> Void
) -> some View {
    VStack(alignment: .leading, spacing: 14) {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Button("选择") {
                action()
            }
            .buttonStyle(.plain)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.sunOrange)
        }

        if items.isEmpty {
            Text("暂未关联")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        Text(item)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
    .glassSurface(tint: AppTheme.surfaceBright.opacity(0.14), padding: 18, cornerRadius: 24)
}
