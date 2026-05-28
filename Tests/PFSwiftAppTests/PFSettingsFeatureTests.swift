import ComposableArchitecture
@testable import PFSwiftApp
import XCTest

@MainActor
final class PFSettingsFeatureTests: XCTestCase {
    func testLoadPreferences() async {
        let preferences = PFSettingsPreferences(
            isAnalyticsEnabled: false,
            isCrashReportingEnabled: true,
            isNotificationAlertsEnabled: false,
            themeMode: .dark
        )
        let store = TestStore(initialState: PFSettingsFeature.State()) {
            PFSettingsFeature()
        } withDependencies: {
            $0.settingsClient.fetchPreferences = { preferences }
        }

        await store.send(.task) {
            $0.isLoading = true
        }
        await store.receive(.loadResponse(.success(preferences))) {
            $0.isAnalyticsEnabled = false
            $0.isCrashReportingEnabled = true
            $0.isLoading = false
            $0.isNotificationAlertsEnabled = false
            $0.themeMode = .dark
        }
    }

    func testAnalyticsChangeSavesPreferences() async {
        let recorder = PFSettingsSaveRecorder()
        let store = TestStore(initialState: PFSettingsFeature.State()) {
            PFSettingsFeature()
        } withDependencies: {
            $0.settingsClient.savePreferences = { preferences in
                await recorder.save(preferences)
            }
        }

        await store.send(.analyticsChanged(false)) {
            $0.isAnalyticsEnabled = false
        }
        await store.receive(.saveSucceeded)

        let preferences = await recorder.savedPreferences()
        XCTAssertEqual(
            preferences,
            PFSettingsPreferences(
                isAnalyticsEnabled: false,
                isCrashReportingEnabled: true,
                isNotificationAlertsEnabled: true,
                themeMode: .system
            )
        )
    }

    func testNotificationAlertsChangeSavesPreferences() async {
        let recorder = PFSettingsSaveRecorder()
        let store = TestStore(initialState: PFSettingsFeature.State()) {
            PFSettingsFeature()
        } withDependencies: {
            $0.settingsClient.savePreferences = { preferences in
                await recorder.save(preferences)
            }
        }

        await store.send(.notificationAlertsChanged(false)) {
            $0.isNotificationAlertsEnabled = false
        }
        await store.receive(.saveSucceeded)

        let preferences = await recorder.savedPreferences()
        XCTAssertEqual(
            preferences,
            PFSettingsPreferences(
                isAnalyticsEnabled: true,
                isCrashReportingEnabled: true,
                isNotificationAlertsEnabled: false,
                themeMode: .system
            )
        )
    }

    func testThemeModeChangeSavesPreferences() async {
        let recorder = PFSettingsSaveRecorder()
        let store = TestStore(initialState: PFSettingsFeature.State()) {
            PFSettingsFeature()
        } withDependencies: {
            $0.settingsClient.savePreferences = { preferences in
                await recorder.save(preferences)
            }
        }

        await store.send(.themeModeChanged(.dark)) {
            $0.themeMode = .dark
        }
        await store.receive(.saveSucceeded)

        let preferences = await recorder.savedPreferences()
        XCTAssertEqual(
            preferences,
            PFSettingsPreferences(
                isAnalyticsEnabled: true,
                isCrashReportingEnabled: true,
                isNotificationAlertsEnabled: true,
                themeMode: .dark
            )
        )
    }

    func testSaveFailureShowsError() async {
        struct SaveFailure: Error {}

        let store = TestStore(initialState: PFSettingsFeature.State()) {
            PFSettingsFeature()
        } withDependencies: {
            $0.settingsClient.savePreferences = { _ in
                throw SaveFailure()
            }
        }

        await store.send(.crashReportingChanged(false)) {
            $0.isCrashReportingEnabled = false
        }
        await store.receive(.saveFailed(PFSettingsClientError(SaveFailure()))) {
            $0.errorMessage = PFSettingsClientError(SaveFailure()).message
        }
        await store.send(.settingsErrorDismissed) {
            $0.errorMessage = nil
        }
    }
}

private actor PFSettingsSaveRecorder {
    private var preferences: PFSettingsPreferences?

    func save(_ preferences: PFSettingsPreferences) {
        self.preferences = preferences
    }

    func savedPreferences() -> PFSettingsPreferences? {
        preferences
    }
}
