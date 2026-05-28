import ComposableArchitecture
@testable import PFSwiftApp
import XCTest

@MainActor
final class PFTaskClientTests: XCTestCase {
    func testLiveFetchTasksUsesAPIClient() async throws {
        let taskID = UUID(uuidString: "ABCDEFAB-CDEF-ABCD-EFAB-CDEFABCDEFAB")!
        let store = TestStore(initialState: PFTasksFeature.State(tasks: [])) {
            PFTasksFeature()
        } withDependencies: {
            $0.taskClient = .liveValue
            $0.apiClient.sendData = { endpoint in
                XCTAssertEqual(endpoint.path, "tasks")
                XCTAssertEqual(endpoint.method, .get)
                return Data(
                    """
                    [
                      {
                        "id": "\(taskID.uuidString)",
                        "title": "Remote task",
                        "isCompleted": false,
                        "priority": "High",
                        "dueDate": "Today"
                      }
                    ]
                    """.utf8
                )
            }
        }

        await store.send(.task) {
            $0.isLoading = true
        }
        await store.receive(
            .loadResponse(
                .success([
                    PFTaskItem(id: taskID, title: "Remote task", priority: .high, dueDate: .today)
                ])
            )
        ) {
            $0.isLoading = false
            $0.tasks = [
                PFTaskItem(id: taskID, title: "Remote task", priority: .high, dueDate: .today)
            ]
        }
    }

    func testLiveSaveTasksUsesAPIClient() async throws {
        let taskID = UUID(uuidString: "BCDEFABC-DEF1-BCDE-FABC-DEFABCDEFABC")!
        let observedEndpoint = PFTaskEndpointRecorder()
        let store = TestStore(
            initialState: PFTasksFeature.State(
                tasks: [
                    PFTaskItem(id: taskID, title: "Persist task")
                ]
            )
        ) {
            PFTasksFeature()
        } withDependencies: {
            $0.taskClient = .liveValue
            $0.apiClient.sendData = { endpoint in
                await observedEndpoint.save(endpoint)
                return Data("{}".utf8)
            }
        }

        await store.send(.taskCompletionToggled(taskID)) {
            $0.tasks[id: taskID]?.isCompleted = true
        }
        await store.receive(.saveSucceeded)

        let endpoint = await observedEndpoint.endpoint()
        XCTAssertEqual(endpoint?.path, "tasks")
        XCTAssertEqual(endpoint?.method, .put)
        XCTAssertEqual(endpoint?.headers["Content-Type"], "application/json")

        let body = try XCTUnwrap(endpoint?.body)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [[String: Any]]
        )
        XCTAssertEqual(json.first?["id"] as? String, taskID.uuidString)
        XCTAssertEqual(json.first?["title"] as? String, "Persist task")
        XCTAssertEqual(json.first?["isCompleted"] as? Bool, true)
        XCTAssertEqual(json.first?["priority"] as? String, "Medium")
        XCTAssertEqual(json.first?["dueDate"] as? String, "No Date")
    }
}

private actor PFTaskEndpointRecorder {
    private var storedEndpoint: PFAPIEndpoint?

    func save(_ endpoint: PFAPIEndpoint) {
        storedEndpoint = endpoint
    }

    func endpoint() -> PFAPIEndpoint? {
        storedEndpoint
    }
}
