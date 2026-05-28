import SwiftUI

enum PFSpacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 24
}

enum PFRadius {
    static let small: CGFloat = 6
    static let medium: CGFloat = 8
}

enum PFSize {
    static let emptyStateImageMaxWidth: CGFloat = 120
    static let compactPickerMaxWidth: CGFloat = 140
}

enum PFTypography {
    static let body = Font.body
    static let headline = Font.headline
    static let subheadline = Font.subheadline
    static let metadata = Font.caption
    static let emptyState = Font.footnote
}

enum PFPalette {
    static let primary = PFAsset.pfPrimary.swiftUIColor
    static let success = PFAsset.pfSuccess.swiftUIColor
    static let warning = PFAsset.pfWarning.swiftUIColor
}

extension View {
    func pfSecondaryText(_ font: Font = PFTypography.metadata) -> some View {
        self
            .font(font)
            .foregroundStyle(.secondary)
    }

    func pfListButtonRow() -> some View {
        self.contentShape(Rectangle())
    }
}
