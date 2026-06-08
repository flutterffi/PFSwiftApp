import ComposableArchitecture
@testable import PFSwiftApp
import XCTest

@MainActor
final class PFSettingsClientTests: XCTestCase {
    func testLiveFetchPreferencesUsesAPIClient() async throws {
        let preferences = PFSettingsPreferences(
            isAnalyticsEnabled: false,
            isCrashReportingEnabled: true,
            isNotificationAlertsEnabled: false,
            themeMode: .dark
        )
        let store = TestStore(initialState: PFSettingsFeature.State()) {
            PFSettingsFeature()
        } withDependencies: {
            $0.settingsClient = .liveValue
            $0.apiClient.sendData = { endpoint in
                XCTAssertEqual(endpoint.path, "settings/preferences")
                XCTAssertEqual(endpoint.method, .get)
                return Data(
                    """
                    {
                      "isAnalyticsEnabled": false,
                      "isCrashReportingEnabled": true,
                      "isNotificationAlertsEnabled": false,
                      "themeMode": "Dark"
                    }
                    """.utf8
                )
            }
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

    func testLiveSavePreferencesUsesAPIClient() async throws {
        let observedEndpoint = PFSettingsEndpointRecorder()
        let store = TestStore(initialState: PFSettingsFeature.State()) {
            PFSettingsFeature()
        } withDependencies: {
            $0.settingsClient = .liveValue
            $0.apiClient.sendData = { endpoint in
                await observedEndpoint.save(endpoint)
                return Data("{}".utf8)
            }
        }

        await store.send(.themeModeChanged(.dark)) {
            $0.themeMode = .dark
        }
        await store.receive(.saveSucceeded)

        let endpoint = await observedEndpoint.endpoint()
        XCTAssertEqual(endpoint?.path, "settings/preferences")
        XCTAssertEqual(endpoint?.method, .put)
        XCTAssertEqual(endpoint?.headers["Content-Type"], "application/json")

        let body = try XCTUnwrap(endpoint?.body)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )
        XCTAssertEqual(json["isAnalyticsEnabled"] as? Bool, true)
        XCTAssertEqual(json["isCrashReportingEnabled"] as? Bool, true)
        XCTAssertEqual(json["isNotificationAlertsEnabled"] as? Bool, true)
        XCTAssertEqual(json["themeMode"] as? String, "Dark")
    }
}

private actor PFSettingsEndpointRecorder {
    private var storedEndpoint: PFAPIEndpoint?

    func save(_ endpoint: PFAPIEndpoint) {
        storedEndpoint = endpoint
    }

    func endpoint() -> PFAPIEndpoint? {
        storedEndpoint
    }
}
