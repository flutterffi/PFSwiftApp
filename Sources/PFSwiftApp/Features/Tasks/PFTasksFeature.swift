import ComposableArchitecture
import Foundation

@Reducer
struct PFTasksFeature {
    @Dependency(\.taskClient) var taskClient
    @Dependency(\.uuid) var uuid

    @ObservableState
    struct State: Equatable {
        var draftTitle = ""
        var errorMessage: String?
        var isLoading = false
        var searchText = ""
        var selectedFilter: PFTaskFilter = .all
        var tasks: IdentifiedArrayOf<PFTaskItem> = IdentifiedArray(uniqueElements: PFTaskItem.defaults)

        var activeTaskCount: Int {
            tasks.filter { !$0.isCompleted }.count
        }

        var completedTaskCount: Int {
            tasks.filter(\.isCompleted).count
        }

        var canAddTask: Bool {
            !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var visibleTasks: IdentifiedArrayOf<PFTaskItem> {
            let filteredTasks: [PFTaskItem]
            switch selectedFilter {
            case .all:
                filteredTasks = Array(tasks)
            case .active:
                filteredTasks = tasks.filter { !$0.isCompleted }
            case .done:
                filteredTasks = tasks.filter(\.isCompleted)
            }

            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else {
                return IdentifiedArray(uniqueElements: filteredTasks)
            }

            return IdentifiedArray(
                uniqueElements: filteredTasks.filter {
                    $0.title.localizedCaseInsensitiveContains(query)
                }
            )
        }
    }

    enum Action: Equatable {
        case task
        case loadResponse(Result<[PFTaskItem], PFTaskClientError>)
        case searchTextChanged(String)
        case filterChanged(PFTaskFilter)
        case draftTitleChanged(String)
        case addButtonTapped
        case taskCompletionToggled(PFTaskItem.ID)
        case delete(IndexSet)
        case clearCompletedButtonTapped
        case saveFailed(PFTaskClientError)
        case saveSucceeded
        case taskErrorDismissed
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                state.errorMessage = nil
                state.isLoading = true
                return .run { send in
                    await send(
                        .loadResponse(
                            Result {
                                try await taskClient.fetchTasks()
                            }
                            .mapError(PFTaskClientError.init)
                        )
                    )
                }

            case let .loadResponse(.success(tasks)):
                state.isLoading = false
                state.tasks = IdentifiedArray(uniqueElements: tasks)
                return .none

            case let .loadResponse(.failure(error)):
                state.errorMessage = error.message
                state.isLoading = false
                return .none

            case let .searchTextChanged(searchText):
                state.searchText = searchText
                return .none

            case let .filterChanged(filter):
                state.selectedFilter = filter
                return .none

            case let .draftTitleChanged(title):
                state.draftTitle = title
                return .none

            case .addButtonTapped:
                let title = state.draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !title.isEmpty else {
                    return .none
                }
                state.tasks.append(PFTaskItem(id: uuid(), title: title))
                state.draftTitle = ""
                return save(state.tasks)

            case let .taskCompletionToggled(id):
                state.tasks[id: id]?.isCompleted.toggle()
                return save(state.tasks)

            case let .delete(indexSet):
                let visibleIDs = indexSet.compactMap { index in
                    state.visibleTasks.indices.contains(index) ? state.visibleTasks[index].id : nil
                }
                for id in visibleIDs {
                    state.tasks.remove(id: id)
                }
                return save(state.tasks)

            case .clearCompletedButtonTapped:
                state.tasks.removeAll { $0.isCompleted }
                return save(state.tasks)

            case let .saveFailed(error):
                state.errorMessage = error.message
                return .none

            case .saveSucceeded:
                return .none

            case .taskErrorDismissed:
                state.errorMessage = nil
                return .none
            }
        }
    }

    private func save(_ tasks: IdentifiedArrayOf<PFTaskItem>) -> Effect<Action> {
        let tasks = Array(tasks)
        return .run { send in
            do {
                try await taskClient.saveTasks(tasks)
                await send(.saveSucceeded)
            } catch {
                await send(.saveFailed(PFTaskClientError(error)))
            }
        }
    }
}

enum PFTaskFilter: String, CaseIterable, Equatable, Identifiable {
    case all = "All"
    case active = "Active"
    case done = "Done"

    var id: String {
        rawValue
    }
}

struct PFTaskItem: Equatable, Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }

    static let defaults = [
        PFTaskItem(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, title: "Review architecture", isCompleted: true),
        PFTaskItem(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, title: "Prepare release tag"),
        PFTaskItem(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, title: "Validate core flow")
    ]
}
