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
            Picker("实体类别", selection: $selectedSection) {
                ForEach(CatalogSection.allCases) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedSection) { _, _ in
                Haptics.selection()
            }

            headerCard

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    switch selectedSection {
                    case .performers:
                        ForEach(performers, id: \.id) { performer in
                            PerformerManagementRow(
                                performer: performer,
                                onEdit: { performerEditorTarget = performer },
                                onDelete: { deletePerformer(performer) }
                            )
                        }
                    case .brands:
                        ForEach(brands, id: \.id) { brand in
                            BrandManagementRow(
                                brand: brand,
                                onEdit: { brandEditorTarget = brand },
                                onDelete: { deleteBrand(brand) }
                            )
                        }
                    case .venues:
                        ForEach(venues, id: \.id) { venue in
                            VenueManagementRow(
                                venue: venue,
                                onEdit: { venueEditorTarget = venue },
                                onDelete: { deleteVenue(venue) }
                            )
                        }
                    }
                }
                .padding(.bottom, 24)
            }
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
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ManagementRowShell(
            title: performer.displayName,
            subtitle: performer.stageName ?? "演员实体",
            countText: "\(performer.shows.count) 场"
        ) {
            onEdit()
        } onDelete: {
            onDelete()
        }
    }
}

private struct BrandManagementRow: View {
    let brand: ProductionBrand
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ManagementRowShell(
            title: brand.displayName,
            subtitle: brand.cityName ?? "厂牌实体",
            countText: "\(brand.shows.count) 场"
        ) {
            onEdit()
        } onDelete: {
            onDelete()
        }
    }
}

private struct VenueManagementRow: View {
    let venue: Venue
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ManagementRowShell(
            title: venue.displayName,
            subtitle: [venue.cityName, venue.district].compactMap { $0 }.joined(separator: " · "),
            countText: "\(venue.shows.count) 场"
        ) {
            onEdit()
        } onDelete: {
            onDelete()
        }
    }
}

private struct ManagementRowShell: View {
    let title: String
    let subtitle: String
    let countText: String
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
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

            Spacer()

            VStack(spacing: 10) {
                Button {
                    Haptics.selection()
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                }

                Button(role: .destructive) {
                    Haptics.warning()
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                }
            }
            .foregroundStyle(AppTheme.textPrimary)
        }
        .glassSurface(tint: AppTheme.surfaceBright.opacity(0.16), padding: 18, cornerRadius: 24)
    }
}

struct PerformerEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let performer: Performer?
    var onSaved: ((Performer) -> Void)? = nil

    @State private var name = ""
    @State private var stageName = ""
    @State private var errorMessage: String?

    var body: some View {
        editorScaffold(title: performer == nil ? "新增演员" : "编辑演员") {
            glassField("演员名称", text: $name)
            glassField("艺名 / 备注", text: $stageName)
        } saveAction: {
            do {
                let service = EntityCatalogService()
                let saved: Performer
                if let performer {
                    try service.updatePerformer(performer, name: name, stageName: stageName, in: modelContext)
                    saved = performer
                } else {
                    saved = try service.createPerformer(name: name, stageName: stageName, in: modelContext)
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
        }
        .alert("保存失败", isPresented: Binding(get: { errorMessage != nil }, set: { newValue in
            if !newValue { errorMessage = nil }
        })) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

struct BrandEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let brand: ProductionBrand?
    var onSaved: ((ProductionBrand) -> Void)? = nil

    @State private var name = ""
    @State private var cityName = ""
    @State private var errorMessage: String?

    var body: some View {
        editorScaffold(title: brand == nil ? "新增厂牌" : "编辑厂牌") {
            glassField("厂牌名称", text: $name)
            glassField("所属城市", text: $cityName)
        } saveAction: {
            do {
                let service = EntityCatalogService()
                let saved: ProductionBrand
                if let brand {
                    try service.updateBrand(brand, name: name, cityName: cityName, in: modelContext)
                    saved = brand
                } else {
                    saved = try service.createBrand(name: name, cityName: cityName, in: modelContext)
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
        }
        .alert("保存失败", isPresented: Binding(get: { errorMessage != nil }, set: { newValue in
            if !newValue { errorMessage = nil }
        })) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

struct VenueEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let venue: Venue?
    var onSaved: ((Venue) -> Void)? = nil

    @State private var name = ""
    @State private var cityName = ""
    @State private var district = ""
    @State private var addressLine = ""
    @State private var errorMessage: String?

    var body: some View {
        editorScaffold(title: venue == nil ? "新增场地" : "编辑场地") {
            glassField("场地名称", text: $name)
            glassField("城市", text: $cityName)
            glassField("区县 / 商圈", text: $district)
            glassField("详细地址", text: $addressLine)
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
                        in: modelContext
                    )
                    saved = venue
                } else {
                    saved = try service.createVenue(
                        name: name,
                        cityName: cityName,
                        addressLine: addressLine,
                        district: district,
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
        }
        .alert("保存失败", isPresented: Binding(get: { errorMessage != nil }, set: { newValue in
            if !newValue { errorMessage = nil }
        })) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
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
