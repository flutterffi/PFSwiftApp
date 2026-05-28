import ComposableArchitecture
@testable import PFSwiftApp
import XCTest

@MainActor
final class PFMessageClientTests: XCTestCase {
    func testLiveFetchThreadsUsesAPIClient() async throws {
        let store = TestStore(initialState: PFMessagesFeature.State(threads: [])) {
            PFMessagesFeature()
        } withDependencies: {
            $0.messageClient = .liveValue
            $0.apiClient.sendData = { endpoint in
                XCTAssertEqual(endpoint.path, "messages/threads")
                XCTAssertEqual(endpoint.method, .get)
                return Data(
                    """
                    [
                      {
                        "id": "support",
                        "title": "Support",
                        "preview": "Ticket updated.",
                        "isUnread": true,
                        "isPinned": false
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
                    PFMessageThread(
                        id: "support",
                        title: "Support",
                        preview: "Ticket updated.",
                        isUnread: true
                    )
                ])
            )
        ) {
            $0.isLoading = false
            $0.threads = [
                PFMessageThread(
                    id: "support",
                    title: "Support",
                    preview: "Ticket updated.",
                    isUnread: true
                )
            ]
        }
    }

    func testLiveSaveThreadsUsesAPIClient() async throws {
        let observedEndpoint = PFMessageEndpointRecorder()
        let store = TestStore(
            initialState: PFMessagesFeature.State(
                threads: [
                    PFMessageThread(
                        id: "support",
                        title: "Support",
                        preview: "Ticket updated.",
                        isUnread: true
                    )
                ]
            )
        ) {
            PFMessagesFeature()
        } withDependencies: {
            $0.messageClient = .liveValue
            $0.apiClient.sendData = { endpoint in
                await observedEndpoint.save(endpoint)
                return Data("{}".utf8)
            }
        }

        await store.send(.pinToggled("support")) {
            $0.threads[id: "support"]?.isPinned = true
        }
        await store.receive(.saveSucceeded)

        let endpoint = await observedEndpoint.endpoint()
        XCTAssertEqual(endpoint?.path, "messages/threads")
        XCTAssertEqual(endpoint?.method, .put)
        XCTAssertEqual(endpoint?.headers["Content-Type"], "application/json")

        let body = try XCTUnwrap(endpoint?.body)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [[String: Any]]
        )
        XCTAssertEqual(json.first?["id"] as? String, "support")
        XCTAssertEqual(json.first?["title"] as? String, "Support")
        XCTAssertEqual(json.first?["preview"] as? String, "Ticket updated.")
        XCTAssertEqual(json.first?["isUnread"] as? Bool, true)
        XCTAssertEqual(json.first?["isPinned"] as? Bool, true)
    }
}

private actor PFMessageEndpointRecorder {
    private var storedEndpoint: PFAPIEndpoint?

    func save(_ endpoint: PFAPIEndpoint) {
        storedEndpoint = endpoint
    }

    func endpoint() -> PFAPIEndpoint? {
        storedEndpoint
    }
}
