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

    func testPinToggle() async {
        let recorder = PFMessageSaveRecorder()
        let store = TestStore(initialState: PFMessagesFeature.State()) {
            PFMessagesFeature()
        } withDependencies: {
            $0.messageClient.saveThreads = { threads in
                await recorder.save(threads)
            }
        }

        await store.send(.pinToggled("Release")) {
            $0.threads[id: "Release"]?.isPinned = true
        }
        await store.receive(.saveSucceeded)
        let savedThreads = await recorder.savedThreads()
        XCTAssertEqual(savedThreads[id: "Release"]?.isPinned, true)
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

    func testVisibleThreadsSortPinnedThenUnreadThenTitle() async {
        let store = TestStore(
            initialState: PFMessagesFeature.State(
                threads: [
                    PFMessageThread(title: "Zulu", preview: "Later."),
                    PFMessageThread(title: "Alpha", preview: "Unread.", isUnread: true),
                    PFMessageThread(title: "Beta", preview: "Pinned.", isPinned: true)
                ]
            )
        ) {
            PFMessagesFeature()
        }

        XCTAssertEqual(
            store.state.visibleThreads,
            [
                PFMessageThread(title: "Beta", preview: "Pinned.", isPinned: true),
                PFMessageThread(title: "Alpha", preview: "Unread.", isUnread: true),
                PFMessageThread(title: "Zulu", preview: "Later.")
            ]
        )
    }

    func testSearchFiltersVisibleThreadsByTitle() async {
        let store = TestStore(
            initialState: PFMessagesFeature.State(
                threads: [
                    PFMessageThread(title: "Support", preview: "Ticket updated."),
                    PFMessageThread(title: "Release", preview: "Tag preparation is queued.")
                ]
            )
        ) {
            PFMessagesFeature()
        }

        await store.send(.searchTextChanged("release")) {
            $0.searchText = "release"
        }
        XCTAssertEqual(
            store.state.visibleThreads,
            [
                PFMessageThread(title: "Release", preview: "Tag preparation is queued.")
            ]
        )
    }

    func testSearchFiltersVisibleThreadsByPreview() async {
        let store = TestStore(
            initialState: PFMessagesFeature.State(
                threads: [
                    PFMessageThread(title: "Support", preview: "Ticket updated."),
                    PFMessageThread(title: "Release", preview: "Tag preparation is queued.")
                ]
            )
        ) {
            PFMessagesFeature()
        }

        await store.send(.searchTextChanged("ticket")) {
            $0.searchText = "ticket"
        }
        XCTAssertEqual(
            store.state.visibleThreads,
            [
                PFMessageThread(title: "Support", preview: "Ticket updated.")
            ]
        )
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
