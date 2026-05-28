import ComposableArchitecture
import SwiftUI

struct PFDashboardView: View {
    let store: StoreOf<PFDashboardFeature>

    var body: some View {
        NavigationStack {
            List {
                Section("Today") {
                    ForEach(store.summaryItems) { item in
                        HStack {
                            Text(item.title)
                            Spacer()
                            Text(item.value)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(store.title)
        }
    }
}
