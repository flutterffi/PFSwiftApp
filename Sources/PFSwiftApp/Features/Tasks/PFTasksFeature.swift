import ComposableArchitecture
import Foundation

struct PFTasksFeature: Reducer {
    @Dependency(\.uuid) var uuid

    struct State: Equatable {
        var draftTitle = ""
        var selectedFilter: PFTaskFilter = .all
        var tasks: IdentifiedArrayOf<PFTaskItem> = [
            PFTaskItem(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, title: "Review architecture", isCompleted: true),
            PFTaskItem(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, title: "Prepare release tag"),
            PFTaskItem(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, title: "Validate core flow")
        ]

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
            switch selectedFilter {
            case .all:
                return tasks
            case .active:
                return IdentifiedArray(uniqueElements: tasks.filter { !$0.isCompleted })
            case .done:
                return IdentifiedArray(uniqueElements: tasks.filter(\.isCompleted))
            }
        }
    }

    enum Action: Equatable {
        case filterChanged(PFTaskFilter)
        case draftTitleChanged(String)
        case addButtonTapped
        case taskCompletionToggled(PFTaskItem.ID)
        case delete(IndexSet)
        case clearCompletedButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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
                return .none

            case let .taskCompletionToggled(id):
                state.tasks[id: id]?.isCompleted.toggle()
                return .none

            case let .delete(indexSet):
                let visibleIDs = indexSet.compactMap { index in
                    state.visibleTasks.indices.contains(index) ? state.visibleTasks[index].id : nil
                }
                for id in visibleIDs {
                    state.tasks.remove(id: id)
                }
                return .none

            case .clearCompletedButtonTapped:
                state.tasks.removeAll { $0.isCompleted }
                return .none
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
}
