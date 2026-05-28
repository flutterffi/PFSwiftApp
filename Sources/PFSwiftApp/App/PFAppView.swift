import ComposableArchitecture
import SwiftUI

struct PFAppView: View {
    let store: StoreOf<PFAppFeature>

    var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: { $0 },
                    send: PFAppFeature.Action.selectedTabChanged
                )
            ) {
                PFDashboardView(
                    store: store.scope(
                        state: \.dashboard,
                        action: PFAppFeature.Action.dashboard
                    )
                )
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.xaxis")
                }
                .tag(PFTab.dashboard)

                PFTasksView(
                    store: store.scope(
                        state: \.tasks,
                        action: PFAppFeature.Action.tasks
                    )
                )
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(PFTab.tasks)

                PFMessagesView(
                    store: store.scope(
                        state: \.messages,
                        action: PFAppFeature.Action.messages
                    )
                )
                .tabItem {
                    Label("Messages", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(PFTab.messages)

                PFSettingsView(
                    store: store.scope(
                        state: \.settings,
                        action: PFAppFeature.Action.settings
                    )
                )
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(PFTab.settings)
            }
        }
    }
}
