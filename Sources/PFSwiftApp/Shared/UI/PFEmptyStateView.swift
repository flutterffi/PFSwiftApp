import SwiftUI

struct PFEmptyStateView: View {
    var title: String

    var body: some View {
        VStack(spacing: PFSpacing.small) {
            PFAsset.pfEmptyState.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: PFSize.emptyStateImageMaxWidth)
                .accessibilityHidden(true)
            Text(title)
                .pfSecondaryText(PFTypography.emptyState)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PFSpacing.medium)
    }
}
