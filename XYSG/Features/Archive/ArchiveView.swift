import SwiftData
import SwiftUI
import XYSGCore

private struct ArchiveFilterState: Equatable {
    var selectedFormat: ShowFormat?
    var selectedBrandID: UUID?
}

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Namespace private var archiveNamespace
    @State private var filters = ArchiveFilterState()
    @State private var showingComposer = false
    @State private var summary = ArchiveStatsSummary(
        totalShows: 0,
        latestShowDate: nil,
        formatCounts: [:],
        roleCounts: [:],
        typeCounts: [:],
        brandCounts: [:]
    )
    @State private var pagedShows: [ShowRecord] = []
    @State private var availableBrands: [ProductionBrand] = []
    @State private var pagination = ArchivePaginationState(pageSize: 20)
    @State private var isLoadingInitialPage = true
    @State private var isLoadingNextPage = false
    @State private var isLoadingMetadata = true
    @State private var didBootstrap = false
    @State private var hasFinishedInitialAppearance = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        statsSection
                        filtersSection
                        cardsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("Archive")
            .toolbarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.softImpact()
                        showingComposer = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.semibold))
                            .padding(6)
                    }
                }
            }
            .sheet(isPresented: $showingComposer) {
                NavigationStack {
                    ComposerView()
                }
                .presentationDetents([.large])
            }
        }
        .task {
            guard !didBootstrap else { return }
            didBootstrap = true
            await bootstrapArchive()
        }
        .onAppear {
            guard didBootstrap else { return }
            guard hasFinishedInitialAppearance else {
                hasFinishedInitialAppearance = true
                return
            }
            Task {
                await refreshArchive()
            }
        }
        .onChange(of: filters) { _, _ in
            Task {
                await reloadArchivePage()
            }
        }
        .onChange(of: showingComposer) { _, isPresented in
            guard !isPresented, didBootstrap else { return }
            Task {
                await refreshArchive()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PERFORMANCE HISTORY")
                .font(.caption.weight(.semibold))
                .tracking(2)
                .foregroundStyle(AppTheme.textSecondary)

            Text("你的演出档案馆。")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("每一场都是一张被灯光照亮的数字票根。")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Snapshot", title: "本阶段积累")

            HStack(spacing: 12) {
                StatPill(title: "总场次", value: isLoadingMetadata ? "..." : "\(summary.totalShows)", accent: AppTheme.sunOrange)
                StatPill(title: "主持", value: isLoadingMetadata ? "..." : "\(summary.roleCounts[.host, default: 0])", accent: AppTheme.skyGlow)
                StatPill(title: "专场", value: isLoadingMetadata ? "..." : "\(summary.typeCounts[.special, default: 0])", accent: AppTheme.amethyst)
            }
        }
    }

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Filter", title: "筛选卡片")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(title: "全部形式", isSelected: filters.selectedFormat == nil) {
                        Haptics.selection()
                        filters.selectedFormat = nil
                    }

                    ForEach(ShowFormat.allCases, id: \.self) { format in
                        FilterChip(
                            title: format.displayName,
                            isSelected: filters.selectedFormat == format,
                            count: isLoadingMetadata ? nil : summary.formatCounts[format]
                        ) {
                            Haptics.selection()
                            filters.selectedFormat = filters.selectedFormat == format ? nil : format
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(title: "全部厂牌", isSelected: filters.selectedBrandID == nil) {
                        Haptics.selection()
                        filters.selectedBrandID = nil
                    }

                    ForEach(availableBrands, id: \.id) { brand in
                        FilterChip(
                            title: brand.displayName,
                            isSelected: filters.selectedBrandID == brand.id,
                            count: isLoadingMetadata ? nil : summary.brandCounts[brand.id]
                        ) {
                            Haptics.selection()
                            filters.selectedBrandID = filters.selectedBrandID == brand.id ? nil : brand.id
                        }
                    }
                }
            }
        }
    }

    private var cardsSection: some View {
        LazyVStack(spacing: 18) {
            if isLoadingInitialPage && pagedShows.isEmpty {
                ForEach(0..<3, id: \.self) { _ in
                    ArchiveLoadingCard()
                        .redacted(reason: .placeholder)
                }
            } else if !isLoadingInitialPage && pagedShows.isEmpty && summary.totalShows == 0 {
                EmptyArchiveView {
                    showingComposer = true
                }
            } else if !isLoadingInitialPage && pagedShows.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    Text("还没有匹配当前筛选的演出。")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("换个筛选，或者先新增一场新的演出卡片。")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassSurface(tint: AppTheme.surfaceBright.opacity(0.2), padding: 20, cornerRadius: 30)
            } else {
                ForEach(pagedShows, id: \.id) { show in
                    NavigationLink {
                        ShowDetailView(show: show, namespace: archiveNamespace)
                    } label: {
                        ShowCard(show: show, namespace: archiveNamespace)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            Haptics.softImpact()
                        }
                    )
                    .onAppear {
                        guard show.id == pagedShows.last?.id else { return }
                        Task {
                            await loadNextPageIfNeeded()
                        }
                    }
                }

                if isLoadingNextPage {
                    ArchiveLoadingCard()
                        .redacted(reason: .placeholder)
                }
            }
        }
    }

    @MainActor
    private func bootstrapArchive() async {
        await Task.yield()
        await reloadArchivePage()
        Task { @MainActor in
            await loadMetadata()
        }
    }

    @MainActor
    private func refreshArchive() async {
        await reloadArchivePage()
        await loadMetadata()
    }

    @MainActor
    private func reloadArchivePage() async {
        isLoadingInitialPage = true
        pagination.reset()
        pagedShows = []
        await Task.yield()

        do {
            let firstPage = try fetchShowPage(offset: pagination.nextFetchOffset, limit: pagination.pageSize)
            pagedShows = firstPage
            pagination.registerLoaded(itemCount: firstPage.count)
        } catch {
            pagedShows = []
            pagination.reset()
        }

        isLoadingInitialPage = false
    }

    @MainActor
    private func loadNextPageIfNeeded() async {
        guard !isLoadingInitialPage, !isLoadingNextPage, pagination.hasMorePages else { return }
        isLoadingNextPage = true

        do {
            let nextPage = try fetchShowPage(offset: pagination.nextFetchOffset, limit: pagination.pageSize)
            pagedShows.append(contentsOf: nextPage)
            pagination.registerLoaded(itemCount: nextPage.count)
        } catch {
            pagination.registerLoaded(itemCount: 0)
        }

        isLoadingNextPage = false
    }

    @MainActor
    private func loadMetadata() async {
        isLoadingMetadata = true
        await Task.yield()

        do {
            let shows = try modelContext.fetch(
                FetchDescriptor<ShowRecord>(
                    sortBy: [SortDescriptor(\ShowRecord.updatedAt, order: .reverse)]
                )
            )
            let brands = try modelContext.fetch(
                FetchDescriptor<ProductionBrand>(
                    sortBy: [SortDescriptor(\ProductionBrand.displayName, order: .forward)]
                )
            )

            summary = ArchiveStatsSummaryCalculator.makeSummary(from: shows.map {
                ShowStatsRecord(
                    date: $0.date,
                    format: $0.format,
                    role: $0.myRole,
                    showType: $0.showType,
                    brandID: $0.brand?.id
                )
            })

            let activeBrandIDs = Set(shows.compactMap { $0.brand?.id })
            availableBrands = brands.filter { activeBrandIDs.contains($0.id) }
        } catch {
            summary = ArchiveStatsSummary(
                totalShows: 0,
                latestShowDate: nil,
                formatCounts: [:],
                roleCounts: [:],
                typeCounts: [:],
                brandCounts: [:]
            )
            availableBrands = []
        }

        isLoadingMetadata = false
    }

    @MainActor
    private func fetchShowPage(offset: Int, limit: Int) throws -> [ShowRecord] {
        var descriptor = FetchDescriptor<ShowRecord>(
            predicate: showPredicate,
            sortBy: [SortDescriptor(\ShowRecord.updatedAt, order: .reverse)]
        )
        descriptor.fetchOffset = offset
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }

    private var showPredicate: Predicate<ShowRecord>? {
        switch (filters.selectedFormat, filters.selectedBrandID) {
        case let (.some(format), .some(brandID)):
            return #Predicate<ShowRecord> {
                $0.format == format && $0.brand?.id == brandID
            }
        case let (.some(format), nil):
            return #Predicate<ShowRecord> {
                $0.format == format
            }
        case let (nil, .some(brandID)):
            return #Predicate<ShowRecord> {
                $0.brand?.id == brandID
            }
        case (nil, nil):
            return nil
        }
    }
}

private struct ArchiveLoadingCard: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(AppTheme.surfaceBright.opacity(0.25))
                .frame(height: 280)

            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.surfaceBright.opacity(0.24))
                    .frame(width: 84, height: 16)
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.surfaceBright.opacity(0.22))
                    .frame(height: 24)
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.surfaceBright.opacity(0.18))
                    .frame(height: 18)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}

private struct EmptyArchiveView: View {
    var createAction: () -> Void

    private let samples = [
        ArchiveShowcaseSample(
            title: "Midnight Laughs",
            subtitle: "The Comedy Atelier · Shanghai",
            format: "单口",
            date: "APR 24"
        ),
        ArchiveShowcaseSample(
            title: "Center Stage",
            subtitle: "The Obsidian Vault · Tokyo",
            format: "主持",
            date: "OCT 26"
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("你的票根档案还在等待第一束追光。")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("先做出第一张卡片，之后这里会慢慢长成属于你的演出生涯展厅。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .glassSurface(tint: AppTheme.surfaceBright.opacity(0.2), padding: 22, cornerRadius: 30)

            ForEach(samples) { sample in
                ArchiveShowcaseCard(sample: sample)
            }

            Button("创建第一场演出") {
                createAction()
            }
            .buttonStyle(GlowButtonStyle())
        }
    }
}

private struct ArchiveShowcaseSample: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let format: String
    let date: String
}

private struct ArchiveShowcaseCard: View {
    let sample: ArchiveShowcaseSample

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LocalCoverArtworkView(
                data: nil,
                storagePath: nil,
                title: sample.title,
                subtitle: sample.subtitle
            )
            .frame(height: 230)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(sample.format)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.sunOrange)
                    Text(sample.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(sample.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Text(sample.date)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .glassSurface(tint: AppTheme.surfaceBright.opacity(0.16), padding: 16, cornerRadius: 30)
    }
}
