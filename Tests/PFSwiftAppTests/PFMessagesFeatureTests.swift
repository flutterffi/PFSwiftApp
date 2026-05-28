import ComposableArchitecture
@testable import PFSwiftApp
import XCTest

@MainActor
final class PFMessagesFeatureTests: XCTestCase {
    func testLoadThreads() async {
        let threads = [
            PFMessageThread(title: "Support", preview: "Ticket updated.", isUnread: true)
        ]
        let store = TestStore(initialState: PFMessagesFeature.State(threads: [])) {
            PFMessagesFeature()
        } withDependencies: {
            $0.messageClient.fetchThreads = { threads }
        }

        await store.send(.task) {
            $0.isLoading = true
        }
        await store.receive(.loadResponse(.success(threads))) {
            $0.isLoading = false
            $0.threads = IdentifiedArray(uniqueElements: threads)
        }
    }

    func testThreadTapSelectsAndMarksRead() async {
        let recorder = PFMessageSaveRecorder()
        let store = TestStore(initialState: PFMessagesFeature.State()) {
            PFMessagesFeature()
        } withDependencies: {
            $0.messageClient.saveThreads = { threads in
                await recorder.save(threads)
            }
        }

        await store.send(.threadTapped("Release")) {
            $0.selectedThreadID = "Release"
            $0.threads[id: "Release"]?.isUnread = false
        }
        await store.receive(.saveSucceeded)
        let savedThreads = await recorder.savedThreads()
        XCTAssertEqual(savedThreads[id: "Release"]?.isUnread, false)
    }

    func testUnreadToggle() async {
        let recorder = PFMessageSaveRecorder()
        let store = TestStore(initialState: PFMessagesFeature.State()) {
            PFMessagesFeature()
        } withDependencies: {
            $0.messageClient.saveThreads = { threads in
                await recorder.save(threads)
            }
        }

        await store.send(.unreadToggled("Platform")) {
            $0.threads[id: "Platform"]?.isUnread = true
        }
        await store.receive(.saveSucceeded)
        let savedThreads = await recorder.savedThreads()
        XCTAssertEqual(savedThreads[id: "Platform"]?.isUnread, true)
    }

    func testMarkAllRead() async {
        let recorder = PFMessageSaveRecorder()
        let store = TestStore(initialState: PFMessagesFeature.State()) {
            PFMessagesFeature()
        } withDependencies: {
            $0.messageClient.saveThreads = { threads in
                await recorder.save(threads)
            }
        }

        await store.send(.markAllReadButtonTapped) {
            $0.threads[id: "Release"]?.isUnread = false
        }
        await store.receive(.saveSucceeded)
        let savedThreads = await recorder.savedThreads()
        XCTAssertEqual(savedThreads.filter(\.isUnread), [])
    }

    func testSaveFailureShowsError() async {
        struct SaveFailure: Error {}

        let store = TestStore(initialState: PFMessagesFeature.State()) {
            PFMessagesFeature()
        } withDependencies: {
            $0.messageClient.saveThreads = { _ in
                throw SaveFailure()
            }
        }

        await store.send(.unreadToggled("Platform")) {
            $0.threads[id: "Platform"]?.isUnread = true
        }
        await store.receive(.saveFailed(PFMessageClientError(SaveFailure()))) {
            $0.errorMessage = PFMessageClientError(SaveFailure()).message
        }
        await store.send(.messageErrorDismissed) {
            $0.errorMessage = nil
        }
    }
}

private actor PFMessageSaveRecorder {
    private var threads: IdentifiedArrayOf<PFMessageThread> = []

    func save(_ threads: [PFMessageThread]) {
        self.threads = IdentifiedArray(uniqueElements: threads)
    }

    func savedThreads() -> IdentifiedArrayOf<PFMessageThread> {
        threads
    }
}
