import ComposableArchitecture
import SwiftUI

struct PFMessagesView: View {
    let store: StoreOf<PFMessagesFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List(viewStore.threads) { thread in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(thread.title)
                            .font(.headline)
                        Text(thread.preview)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle("Messages")
            }
        }
    }
}
