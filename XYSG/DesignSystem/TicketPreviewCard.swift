import SwiftUI
import XYSGCore

struct TicketPreviewCard: View {
    let draft: ComposerDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(draft.showType.displayName.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(1.6)
                        .foregroundStyle(AppTheme.sunOrange)

                    Text(draft.storedTitle)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(2)

                    Text(draft.selectedBrandName.isEmpty ? "未填写厂牌" : draft.selectedBrandName)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 54, height: 54)
                    .overlay {
                        Image(systemName: "waveform.path.ecg.rectangle")
                            .font(.title3)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
            }

            LocalCoverArtworkView(
                data: draft.coverData,
                storagePath: draft.coverStoragePath,
                title: draft.storedTitle,
                subtitle: draft.selectedBrandName,
                showsTextOverlay: false
            )
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let date = draft.date {
                        Text(AppTheme.dayFormatter.string(from: date).uppercased())
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.sunOrange)
                        Text(AppTheme.timeFormatter.string(from: date))
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textPrimary)
                    } else {
                        Text(ShowPresentation.pendingDateLabel)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(draft.format.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(draft.myRole.displayName)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .glassSurface(tint: AppTheme.amethyst.opacity(0.22), padding: 18, cornerRadius: 28)
    }
}
