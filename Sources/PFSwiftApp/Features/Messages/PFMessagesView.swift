import ComposableArchitecture
import SwiftUI

struct PFMessagesView: View {
    @Bindable var store: StoreOf<PFMessagesFeature>

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField(
                        "Search messages",
                        text: $store.searchText.sending(\.searchTextChanged)
                    )
                }

                Section {
                    ForEach(store.visibleThreads) { thread in
                        Button {
                            store.send(.threadTapped(thread.id))
                        } label: {
                            HStack(spacing: PFSpacing.medium) {
                                Image(systemName: thread.isUnread ? "circle.fill" : "circle")
                                    .font(PFTypography.metadata)
                                    .foregroundStyle(thread.isUnread ? PFPalette.primary : .secondary)

                                VStack(alignment: .leading, spacing: PFSpacing.xSmall) {
                                    HStack(spacing: PFSpacing.small) {
                                        Text(thread.title)
                                            .font(PFTypography.headline)
                                        if thread.isPinned {
                                            Image(systemName: "pin.fill")
                                                .font(PFTypography.metadata)
                                                .foregroundStyle(PFPalette.warning)
                                        }
                                    }
                                    Text(thread.preview)
                                        .pfSecondaryText(PFTypography.subheadline)
                                }

                                Spacer()

                                Button {
                                    store.send(.pinToggled(thread.id))
                                } label: {
                                    Image(systemName: thread.isPinned ? "pin.slash" : "pin")
                                }
                                .buttonStyle(.borderless)

                                Button {
                                    store.send(.unreadToggled(thread.id))
                                } label: {
                                    Image(systemName: thread.isUnread ? "envelope.open" : "envelope.badge")
                                }
                                .buttonStyle(.borderless)
                            }
                            .pfListButtonRow()
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("\(store.unreadThreadCount) Unread")
                } footer: {
                    if store.visibleThreads.isEmpty {
                        PFEmptyStateView(title: PFStrings.Messages.Empty.title)
                    } else {
                        Text("\(store.pinnedThreadCount) Pinned")
                    }
                }
            }
            .navigationTitle("Messages")
            .overlay {
                if store.isLoading {
                    ProgressView()
                }
            }
            .alert(
                "Message Error",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            store.send(.messageErrorDismissed)
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(store.errorMessage ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Mark All Read") {
                        store.send(.markAllReadButtonTapped)
                    }
                    .disabled(store.unreadThreadCount == 0)
                }
            }
            .task {
                await store.send(.task).finish()
            }
        }
    }
}
