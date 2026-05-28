import ComposableArchitecture
import SwiftUI

struct PFMessagesView: View {
    let store: StoreOf<PFMessagesFeature>

    var body: some View {
        NavigationStack {
            List(store.threads) { thread in
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
