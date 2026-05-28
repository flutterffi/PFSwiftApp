import ComposableArchitecture
import SwiftUI

struct PFDashboardView: View {
    let store: StoreOf<PFDashboardFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section("Today") {
                        ForEach(viewStore.summaryItems) { item in
                            HStack {
                                Text(item.title)
                                Spacer()
                                Text(item.value)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle(viewStore.title)
            }
        }
    }
}
