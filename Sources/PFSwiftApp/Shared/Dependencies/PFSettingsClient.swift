import ComposableArchitecture

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
                isCrashReportingEnabled: true
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
        isCrashReportingEnabled: true
    )

    func fetchPreferences() -> PFSettingsPreferences {
        preferences
    }

    func savePreferences(_ preferences: PFSettingsPreferences) {
        self.preferences = preferences
    }
}
