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
                Label("Dashboard", systemImage: "chart.bar.xaxis")
            }
            .tag(PFTab.dashboard)

            PFTasksView(
                store: store.scope(state: \.tasks, action: \.tasks)
            )
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            .tag(PFTab.tasks)

            PFMessagesView(
                store: store.scope(state: \.messages, action: \.messages)
            )
            .tabItem {
                Label("Messages", systemImage: "bubble.left.and.bubble.right")
            }
            .tag(PFTab.messages)

            PFSettingsView(
                store: store.scope(state: \.settings, action: \.settings)
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(PFTab.settings)
        }
    }
}
