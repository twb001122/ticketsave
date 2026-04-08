import SwiftData
import SwiftUI
import XYSGCore

struct ShowDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let show: ShowRecord
    let namespace: Namespace.ID
    var onShowDeleted: () -> Void = {}

    @State private var isPresentingEditor = false
    @State private var notesDraft = ""
    @State private var deletionError: String?
    @State private var showDeleteAlert = false

    private let heroHeight: CGFloat = 360
    private let infoLayerOverlap: CGFloat = 66
    private let primaryCardLift: CGFloat = 78

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    hero(topInset: topInset)

                    detailInfoLayer
                        .offset(y: -infoLayerOverlap)
                        .padding(.bottom, -infoLayerOverlap)
                }
            }
            .coordinateSpace(name: "detailScroll")
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .ignoresSafeArea(edges: .top)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isPresentingEditor = true
                } label: {
                    detailToolbarIcon("slider.horizontal.3")
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    detailToolbarIcon("trash")
                }
                .buttonStyle(.plain)
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

    private func hero(topInset: CGFloat) -> some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .named("detailScroll")).minY
            let stretch = max(0, minY)
            let parallax = minY < 0 ? minY * 0.14 : -stretch * 0.02

            ZStack(alignment: .bottom) {
                LocalCoverArtworkView(
                    storagePath: show.coverStoragePath,
                    title: show.displayTitle,
                    subtitle: show.brand?.displayName ?? show.venueDisplay,
                    showsTextOverlay: false
                )
                .frame(maxWidth: .infinity)
                .frame(height: heroHeight + topInset + stretch)
                .offset(y: parallax)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.24),
                                .clear,
                                AppTheme.background.opacity(0.10),
                                AppTheme.background.opacity(0.68),
                                AppTheme.background,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                LinearGradient(
                    colors: [
                        .clear,
                        AppTheme.background.opacity(0.18),
                        AppTheme.background.opacity(0.94),
                        AppTheme.background,
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 220)
            }
            .frame(height: heroHeight + topInset + stretch)
            .clipped()
        }
        .frame(height: heroHeight + topInset)
    }

    private var detailInfoLayer: some View {
        VStack(alignment: .leading, spacing: 18) {
            primaryInfoCard
                .offset(y: -primaryCardLift)
                .padding(.bottom, -primaryCardLift)
                .zIndex(2)

            highlightsSection
            additionalInfoSection
            lineupSection
            notesSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 6 + primaryCardLift)
        .padding(.bottom, 42)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(AppTheme.background)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(AppTheme.glassFillHighlight.opacity(0.22))
                        .frame(height: 1)
                }
                .shadow(color: AppTheme.elevationShadow.opacity(0.06), radius: 14, y: -4)
        }
    }

    private var primaryInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 16) {
                Text(show.displayTitle)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Label {
                    Text(brandValue)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                } icon: {
                    Image(systemName: "ticket.fill")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(AppTheme.sunOrange)
                .fixedSize(horizontal: true, vertical: false)
            }

            DetailTagWrap {
                detailTag(show.format.displayName, accent: show.format.accentToken.primaryColor)
                detailTag(show.myRole.displayName, accent: AppTheme.skyGlow)
                detailTag(show.showType.displayName, accent: AppTheme.amethyst)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .glassSurface(tint: AppTheme.surfaceBright.opacity(0.13), padding: 22, cornerRadius: 30)
        .shadow(color: AppTheme.elevationShadow.opacity(0.14), radius: 16, y: 8)
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Highlights", title: "重要信息")

            HStack(alignment: .top, spacing: 12) {
                ForEach(highlightCards) { card in
                    DetailHighlightCard(card: card)
                }
            }
        }
    }

    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(eyebrow: "Archive Notes", title: "更多资料")

            VStack(spacing: 0) {
                ForEach(Array(additionalRows.enumerated()), id: \.offset) { index, row in
                    DetailInfoRow(row: row)

                    if index < additionalRows.count - 1 {
                        Divider()
                            .overlay(AppTheme.glassStroke.opacity(0.45))
                            .padding(.leading, 42)
                    }
                }
            }
            .glassSurface(tint: AppTheme.surfaceBright.opacity(0.12), padding: 16, cornerRadius: 28)
        }
    }

    private var lineupSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(eyebrow: "Lineup", title: "演员阵容")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    if show.performers.isEmpty {
                        DetailPerformerCard(name: "待补充阵容", systemImage: "person.2.slash.fill", isPlaceholder: true)
                    } else {
                        ForEach(show.performers, id: \.id) { performer in
                            DetailPerformerCard(name: performer.displayName, systemImage: "person.fill")
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
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
                .glassSurface(tint: AppTheme.surfaceBright.opacity(0.14), padding: 12, cornerRadius: 28)

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

    private var brandValue: String {
        ShowDetailPresentation.brandValue(brandName: show.brand?.displayName)
    }

    private var highlightCards: [DetailHighlightData] {
        let dateContent = ShowDetailPresentation.dateHighlightContent(for: show.date)
        let venueContent = ShowDetailPresentation.venueHighlightContent(
            venueName: show.venue?.displayName,
            district: show.venue?.district,
            cityName: show.venue?.cityName
        )
        let locationContent = ShowDetailPresentation.locationHighlightContent(
            cityName: show.venue?.cityName,
            district: show.venue?.district
        )

        return [
            DetailHighlightData(
                title: "日期时间",
                primary: dateContent.primary,
                secondary: dateContent.secondary,
                systemImage: "calendar.badge.clock",
                accent: AppTheme.sunOrange
            ),
            DetailHighlightData(
                title: "剧场",
                primary: venueContent.primary,
                secondary: venueContent.secondary,
                systemImage: "building.2.fill",
                accent: AppTheme.skyGlow
            ),
            DetailHighlightData(
                title: "城市地点",
                primary: locationContent.primary,
                secondary: locationContent.secondary,
                systemImage: "mappin.and.ellipse",
                accent: AppTheme.berryGlow
            )
        ]
    }

    private var additionalRows: [ShowDetailPresentation.DetailRow] {
        ShowDetailPresentation.additionalRows(
            formatDisplayName: show.format.displayName,
            roleDisplayName: show.myRole.displayName,
            showTypeDisplayName: show.showType.displayName,
            brandName: show.brand?.displayName,
            updatedAt: show.updatedAt
        )
    }

    private func detailTag(_ text: String, accent: Color) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accent.opacity(0.22),
                                        AppTheme.glassFillHighlight,
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(AppTheme.glassStroke)
                    }
            )
    }

    private func detailToolbarIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.white)
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
    }

    private func deleteShow() {
        do {
            try ShowRecordDeletionService().delete(show, in: modelContext)
            onShowDeleted()
            Haptics.success()
            dismiss()
        } catch {
            Haptics.warning()
            deletionError = error.localizedDescription
        }
    }
}

private struct DetailHighlightData: Identifiable {
    let id = UUID()
    let title: String
    let primary: String
    let secondary: String
    let systemImage: String
    let accent: Color
}

private struct DetailHighlightCard: View {
    let card: DetailHighlightData

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(card.accent.opacity(0.12))
                    .frame(width: 28, height: 28)

                Image(systemName: card.systemImage)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(card.accent)
            }

            Text(card.primary)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            VStack(alignment: .center, spacing: 2) {
                Text(card.secondary)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(card.accent)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 96, maxHeight: 96, alignment: .center)
        .glassSurface(tint: card.accent.opacity(0.08), padding: 12, cornerRadius: 22)
    }
}

private struct DetailInfoRow: View {
    let row: ShowDetailPresentation.DetailRow

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: row.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.sunOrange)
                    .frame(width: 18, height: 18)

                Text(row.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer(minLength: 0)

            Text(row.value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
    }
}

private struct DetailPerformerCard: View {
    let name: String
    let systemImage: String
    var isPlaceholder = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.sunOrange.opacity(isPlaceholder ? 0.08 : 0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isPlaceholder ? AppTheme.textSecondary : AppTheme.sunOrange)
            }

            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 138, alignment: .leading)
        .glassSurface(tint: AppTheme.surfaceHigh.opacity(0.08), padding: 14, cornerRadius: 20)
    }
}

private struct DetailTagWrap<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ViewThatFits(in: .vertical) {
            HStack(spacing: 10) {
                content
            }

            VStack(alignment: .leading, spacing: 10) {
                content
            }
        }
    }
}
