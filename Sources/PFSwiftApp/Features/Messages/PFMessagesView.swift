import ComposableArchitecture
import SwiftUI

struct PFMessagesView: View {
    let store: StoreOf<PFMessagesFeature>

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.threads) { thread in
                        Button {
                            store.send(.threadTapped(thread.id))
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: thread.isUnread ? "circle.fill" : "circle")
                                    .font(.caption)
                                    .foregroundStyle(thread.isUnread ? .blue : .secondary)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(thread.title)
                                        .font(.headline)
                                    Text(thread.preview)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Button {
                                    store.send(.unreadToggled(thread.id))
                                } label: {
                                    Image(systemName: thread.isUnread ? "envelope.open" : "envelope.badge")
                                }
                                .buttonStyle(.borderless)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("\(store.unreadThreadCount) Unread")
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Mark All Read") {
                        store.send(.markAllReadButtonTapped)
                    }
                    .disabled(store.unreadThreadCount == 0)
                }
            }
        }
    }
}
