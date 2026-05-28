import ComposableArchitecture
import SwiftUI

struct PFTasksView: View {
    let store: StoreOf<PFTasksFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section {
                        HStack(spacing: 12) {
                            TextField(
                                "New task",
                                text: viewStore.binding(
                                    get: \.draftTitle,
                                    send: PFTasksFeature.Action.draftTitleChanged
                                )
                            )

                            Button {
                                viewStore.send(.addButtonTapped)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large)
                            }
                            .disabled(!viewStore.canAddTask)
                            .buttonStyle(.borderless)
                        }
                    }

                    Section {
                        ForEach(viewStore.tasks) { task in
                            Button {
                                viewStore.send(.taskCompletionToggled(task.id))
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(task.isCompleted ? .green : .secondary)
                                    Text(task.title)
                                        .strikethrough(task.isCompleted)
                                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { indexSet in
                            viewStore.send(.delete(indexSet))
                        }
                    } header: {
                        Text("\(viewStore.activeTaskCount) Active")
                    }
                }
                .navigationTitle("Tasks")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Clear Done") {
                            viewStore.send(.clearCompletedButtonTapped)
                        }
                    }
                }
            }
        }
    }
}
