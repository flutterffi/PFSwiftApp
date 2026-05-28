import SwiftUI

struct PFEmptyStateView: View {
    var title: String

    var body: some View {
        VStack(spacing: 8) {
            PFAsset.pfEmptyState.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 120)
                .accessibilityHidden(true)
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
