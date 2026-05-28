import ComposableArchitecture
import SwiftUI

struct PFTasksView: View {
    @Bindable var store: StoreOf<PFTasksFeature>

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField(
                        "Search tasks",
                        text: $store.searchText.sending(\.searchTextChanged)
                    )
                }

                Section {
                    Picker(
                        "Filter",
                        selection: $store.selectedFilter.sending(\.filterChanged)
                    ) {
                        ForEach(PFTaskFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    HStack(spacing: 12) {
                        TextField(
                            "New task",
                            text: $store.draftTitle.sending(\.draftTitleChanged)
                        )

                        Picker(
                            "Priority",
                            selection: $store.selectedPriority.sending(\.selectedPriorityChanged)
                        ) {
                            ForEach(PFTaskPriority.allCases) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: 120)

                        Button {
                            store.send(.addButtonTapped)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.large)
                        }
                        .disabled(!store.canAddTask)
                        .buttonStyle(.borderless)
                    }
                }

                Section {
                    ForEach(store.visibleTasks) { task in
                        Button {
                            store.send(.taskCompletionToggled(task.id))
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                                Text(task.title)
                                    .strikethrough(task.isCompleted)
                                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                                Text(task.priority.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()

                                Menu {
                                    ForEach(PFTaskPriority.allCases) { priority in
                                        Button(priority.rawValue) {
                                            store.send(.priorityChanged(task.id, priority))
                                        }
                                    }
                                } label: {
                                    Image(systemName: "flag")
                                }
                                .buttonStyle(.borderless)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        store.send(.delete(indexSet))
                    }
                } header: {
                    Text("\(store.activeTaskCount) Active")
                } footer: {
                    if store.visibleTasks.isEmpty {
                        Text("No tasks in this view.")
                    }
                }
            }
            .navigationTitle("Tasks")
            .overlay {
                if store.isLoading {
                    ProgressView()
                }
            }
            .alert(
                "Task Error",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            store.send(.taskErrorDismissed)
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
                    Button("Clear Done") {
                        store.send(.clearCompletedButtonTapped)
                    }
                }
            }
            .task {
                await store.send(.task).finish()
            }
        }
    }
}
