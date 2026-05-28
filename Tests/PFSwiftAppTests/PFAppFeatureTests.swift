import ComposableArchitecture
@testable import PFSwiftApp
import XCTest

@MainActor
final class PFAppFeatureTests: XCTestCase {
    func testDashboardTaskSummaryUpdatesAfterTaskAction() async {
        let taskID = UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!
        let store = TestStore(
            initialState: PFAppFeature.State(
                tasks: PFTasksFeature.State(
                    tasks: [
                        PFTaskItem(id: taskID, title: "Open")
                    ]
                )
            )
        ) {
            PFAppFeature()
        } withDependencies: {
            $0.taskClient.saveTasks = { _ in }
        }

        await store.send(.tasks(.taskCompletionToggled(taskID))) {
            $0.tasks.tasks[id: taskID]?.isCompleted = true
            $0.dashboard.taskSummaryItems = [
                PFDashboardSummary(title: "Open Tasks", value: "0"),
                PFDashboardSummary(title: "High Priority", value: "0"),
                PFDashboardSummary(title: "Done Tasks", value: "1"),
                PFDashboardSummary(title: "Total Tasks", value: "1")
            ]
            $0.dashboard.messageSummaryItems = [
                PFDashboardSummary(title: "Unread Messages", value: "1"),
                PFDashboardSummary(title: "Total Messages", value: "2")
            ]
            $0.dashboard.systemSummaryItems = [
                PFDashboardSummary(title: "Theme", value: "System"),
                PFDashboardSummary(title: "Analytics", value: "On"),
                PFDashboardSummary(title: "Crash Reporting", value: "On")
            ]
        }
        await store.receive(.tasks(.saveSucceeded))
    }

    func testDashboardSystemSummaryUpdatesAfterSettingsAction() async {
        let store = TestStore(initialState: PFAppFeature.State()) {
            PFAppFeature()
        } withDependencies: {
            $0.settingsClient.savePreferences = { _ in }
        }

        await store.send(.settings(.analyticsChanged(false))) {
            $0.settings.isAnalyticsEnabled = false
            $0.dashboard.taskSummaryItems = [
                PFDashboardSummary(title: "Open Tasks", value: "2"),
                PFDashboardSummary(title: "High Priority", value: "1"),
                PFDashboardSummary(title: "Done Tasks", value: "1"),
                PFDashboardSummary(title: "Total Tasks", value: "3")
            ]
            $0.dashboard.messageSummaryItems = [
                PFDashboardSummary(title: "Unread Messages", value: "1"),
                PFDashboardSummary(title: "Total Messages", value: "2")
            ]
            $0.dashboard.systemSummaryItems = [
                PFDashboardSummary(title: "Theme", value: "System"),
                PFDashboardSummary(title: "Analytics", value: "Off"),
                PFDashboardSummary(title: "Crash Reporting", value: "On")
            ]
        }
        await store.receive(.settings(.saveSucceeded))
    }

    func testDashboardMessageSummaryUpdatesAfterMessageAction() async {
        let store = TestStore(initialState: PFAppFeature.State()) {
            PFAppFeature()
        } withDependencies: {
            $0.messageClient.saveThreads = { _ in }
        }

        await store.send(.messages(.markAllReadButtonTapped)) {
            $0.messages.threads[id: "Release"]?.isUnread = false
            $0.dashboard.taskSummaryItems = [
                PFDashboardSummary(title: "Open Tasks", value: "2"),
                PFDashboardSummary(title: "High Priority", value: "1"),
                PFDashboardSummary(title: "Done Tasks", value: "1"),
                PFDashboardSummary(title: "Total Tasks", value: "3")
            ]
            $0.dashboard.messageSummaryItems = [
                PFDashboardSummary(title: "Unread Messages", value: "0"),
                PFDashboardSummary(title: "Total Messages", value: "2")
            ]
            $0.dashboard.systemSummaryItems = [
                PFDashboardSummary(title: "Theme", value: "System"),
                PFDashboardSummary(title: "Analytics", value: "On"),
                PFDashboardSummary(title: "Crash Reporting", value: "On")
            ]
        }
        await store.receive(.messages(.saveSucceeded))
    }

    func testDashboardThemeSummaryUpdatesAfterThemeAction() async {
        let store = TestStore(initialState: PFAppFeature.State()) {
            PFAppFeature()
        } withDependencies: {
            $0.settingsClient.savePreferences = { _ in }
        }

        await store.send(.settings(.themeModeChanged(.dark))) {
            $0.settings.themeMode = .dark
            $0.dashboard.taskSummaryItems = [
                PFDashboardSummary(title: "Open Tasks", value: "2"),
                PFDashboardSummary(title: "High Priority", value: "1"),
                PFDashboardSummary(title: "Done Tasks", value: "1"),
                PFDashboardSummary(title: "Total Tasks", value: "3")
            ]
            $0.dashboard.messageSummaryItems = [
                PFDashboardSummary(title: "Unread Messages", value: "1"),
                PFDashboardSummary(title: "Total Messages", value: "2")
            ]
            $0.dashboard.systemSummaryItems = [
                PFDashboardSummary(title: "Theme", value: "Dark"),
                PFDashboardSummary(title: "Analytics", value: "On"),
                PFDashboardSummary(title: "Crash Reporting", value: "On")
            ]
        }
        await store.receive(.settings(.saveSucceeded))
    }
}
