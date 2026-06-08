import ComposableArchitecture
import Foundation

struct PFSettingsClient: Sendable {
    var fetchPreferences: @Sendable () async throws -> PFSettingsPreferences
    var savePreferences: @Sendable (PFSettingsPreferences) async throws -> Void
}

struct PFSettingsClientError: Error, Equatable, Sendable {
    var message: String

    init(_ error: Error) {
        self.message = error.localizedDescription
    }

    init(message: String) {
        self.message = message
    }
}

extension PFSettingsClient: DependencyKey {
    static let liveValue: PFSettingsClient = {
        return PFSettingsClient(
            fetchPreferences: {
                @Dependency(\.apiClient) var apiClient
                return try await apiClient.send(
                    PFSettingsEndpoint.preferences,
                    as: PFSettingsPreferences.self
                )
            },
            savePreferences: { preferences in
                @Dependency(\.apiClient) var apiClient
                _ = try await apiClient.send(
                    PFSettingsEndpoint.save(preferences),
                    as: PFEmptyResponse.self
                )
            }
        )
    }()

    static let previewValue: PFSettingsClient = {
        let storage = PFSettingsStorage()
        return PFSettingsClient(
            fetchPreferences: {
                await storage.fetchPreferences()
            },
            savePreferences: { preferences in
                await storage.savePreferences(preferences)
            }
        )
    }()

    static let testValue = PFSettingsClient(
        fetchPreferences: {
            reportIssue("PFSettingsClient.fetchPreferences is unimplemented")
            return PFSettingsPreferences(
                isAnalyticsEnabled: true,
                isCrashReportingEnabled: true,
                isNotificationAlertsEnabled: true,
                themeMode: .system
            )
        },
        savePreferences: { _ in
            reportIssue("PFSettingsClient.savePreferences is unimplemented")
        }
    )
}

extension DependencyValues {
    var settingsClient: PFSettingsClient {
        get { self[PFSettingsClient.self] }
        set { self[PFSettingsClient.self] = newValue }
    }
}

private actor PFSettingsStorage {
    private var preferences = PFSettingsPreferences(
        isAnalyticsEnabled: true,
        isCrashReportingEnabled: true,
        isNotificationAlertsEnabled: true,
        themeMode: .system
    )

    func fetchPreferences() -> PFSettingsPreferences {
        preferences
    }

    func savePreferences(_ preferences: PFSettingsPreferences) {
        self.preferences = preferences
    }
}

private enum PFSettingsEndpoint {
    static let preferences = PFAPIEndpoint(path: "settings/preferences")

    static func save(_ preferences: PFSettingsPreferences) throws -> PFAPIEndpoint {
        let body = try PFAPIJSONCoding.encode(preferences)
        return PFAPIEndpoint(
            path: "settings/preferences",
            method: .put,
            headers: ["Content-Type": "application/json"],
            body: body
        )
    }
}
