import ComposableArchitecture
@testable import PFSwiftApp
import XCTest

@MainActor
final class PFMessagesFeatureTests: XCTestCase {
    func testThreadTapSelectsAndMarksRead() async {
        let store = TestStore(initialState: PFMessagesFeature.State()) {
            PFMessagesFeature()
        }

        await store.send(.threadTapped("Release")) {
            $0.selectedThreadID = "Release"
            $0.threads[id: "Release"]?.isUnread = false
        }
    }

    func testUnreadToggle() async {
        let store = TestStore(initialState: PFMessagesFeature.State()) {
            PFMessagesFeature()
        }

        await store.send(.unreadToggled("Platform")) {
            $0.threads[id: "Platform"]?.isUnread = true
        }
    }

    func testMarkAllRead() async {
        let store = TestStore(initialState: PFMessagesFeature.State()) {
            PFMessagesFeature()
        }

        await store.send(.markAllReadButtonTapped) {
            $0.threads[id: "Release"]?.isUnread = false
        }
    }
}
