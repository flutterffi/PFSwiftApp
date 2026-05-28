import ComposableArchitecture
import Foundation

struct PFTasksFeature: Reducer {
    @Dependency(\.uuid) var uuid

    struct State: Equatable {
        var draftTitle = ""
        var tasks: IdentifiedArrayOf<PFTaskItem> = [
            PFTaskItem(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, title: "Review architecture", isCompleted: true),
            PFTaskItem(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, title: "Prepare release tag"),
            PFTaskItem(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, title: "Validate core flow")
        ]

        var activeTaskCount: Int {
            tasks.filter { !$0.isCompleted }.count
        }

        var canAddTask: Bool {
            !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    enum Action: Equatable {
        case draftTitleChanged(String)
        case addButtonTapped
        case taskCompletionToggled(PFTaskItem.ID)
        case delete(IndexSet)
        case clearCompletedButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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
                state.tasks.remove(atOffsets: indexSet)
                return .none

            case .clearCompletedButtonTapped:
                state.tasks.removeAll { $0.isCompleted }
                return .none
            }
        }
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
