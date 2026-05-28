import ComposableArchitecture
import SwiftUI

struct PFAppView: View {
    @Bindable var store: StoreOf<PFAppFeature>

    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.selectedTabChanged)) {
            PFDashboardView(
                store: store.scope(state: \.dashboard, action: \.dashboard)
            )
            .tabItem {
                PFAsset.pfTabDashboard.swiftUIImage
                    .renderingMode(.template)
                Text(PFStrings.Tab.dashboard)
            }
            .tag(PFTab.dashboard)

            PFTasksView(
                store: store.scope(state: \.tasks, action: \.tasks)
            )
            .tabItem {
                PFAsset.pfTabTasks.swiftUIImage
                    .renderingMode(.template)
                Text(PFStrings.Tab.tasks)
            }
            .tag(PFTab.tasks)

            PFMessagesView(
                store: store.scope(state: \.messages, action: \.messages)
            )
            .tabItem {
                PFAsset.pfTabMessages.swiftUIImage
                    .renderingMode(.template)
                Text(PFStrings.Tab.messages)
            }
            .tag(PFTab.messages)

            PFSettingsView(
                store: store.scope(state: \.settings, action: \.settings)
            )
            .tabItem {
                PFAsset.pfTabSettings.swiftUIImage
                    .renderingMode(.template)
                Text(PFStrings.Tab.settings)
            }
            .tag(PFTab.settings)
        }
        .tint(PFAsset.pfPrimary.swiftUIColor)
        .preferredColorScheme(store.settings.themeMode.colorScheme)
    }
}

private extension PFThemeMode {
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
