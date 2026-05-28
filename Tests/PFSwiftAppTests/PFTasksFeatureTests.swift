import ComposableArchitecture
@testable import PFSwiftApp
import XCTest

@MainActor
final class PFTasksFeatureTests: XCTestCase {
    func testAddTask() async {
        let taskID = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!
        let store = TestStore(initialState: PFTasksFeature.State(tasks: [])) {
            PFTasksFeature()
        } withDependencies: {
            $0.uuid = .constant(taskID)
        }

        await store.send(.draftTitleChanged("Ship baseline")) {
            $0.draftTitle = "Ship baseline"
        }
        await store.send(.addButtonTapped) {
            $0.draftTitle = ""
            $0.tasks = [
                PFTaskItem(id: taskID, title: "Ship baseline")
            ]
        }
    }

    func testToggleAndClearCompletedTasks() async {
        let taskID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        let store = TestStore(
            initialState: PFTasksFeature.State(
                tasks: [
                    PFTaskItem(id: taskID, title: "Done later")
                ]
            )
        ) {
            PFTasksFeature()
        }

        await store.send(.taskCompletionToggled(taskID)) {
            $0.tasks[id: taskID]?.isCompleted = true
        }
        await store.send(.clearCompletedButtonTapped) {
            $0.tasks = []
        }
    }

    func testFilterAndDeleteVisibleTask() async {
        let activeID = UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!
        let doneID = UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!
        let store = TestStore(
            initialState: PFTasksFeature.State(
                selectedFilter: .done,
                tasks: [
                    PFTaskItem(id: activeID, title: "Active task"),
                    PFTaskItem(id: doneID, title: "Done task", isCompleted: true)
                ]
            )
        ) {
            PFTasksFeature()
        }

        await store.send(.filterChanged(.done))
        await store.send(.delete(IndexSet(integer: 0))) {
            $0.tasks = [
                PFTaskItem(id: activeID, title: "Active task")
            ]
        }
    }
}
