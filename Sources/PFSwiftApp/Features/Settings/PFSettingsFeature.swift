import ComposableArchitecture

@Reducer
struct PFSettingsFeature {
    @Dependency(\.settingsClient) var settingsClient

    @ObservableState
    struct State: Equatable {
        var errorMessage: String?
        var isLoading = false
        var isAnalyticsEnabled = true
        var isCrashReportingEnabled = true
        var themeMode: PFThemeMode = .system
    }

    enum Action: Equatable {
        case analyticsChanged(Bool)
        case crashReportingChanged(Bool)
        case loadResponse(Result<PFSettingsPreferences, PFSettingsClientError>)
        case saveFailed(PFSettingsClientError)
        case saveSucceeded
        case settingsErrorDismissed
        case task
        case themeModeChanged(PFThemeMode)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .analyticsChanged(isEnabled):
                state.isAnalyticsEnabled = isEnabled
                return save(state)

            case let .crashReportingChanged(isEnabled):
                state.isCrashReportingEnabled = isEnabled
                return save(state)

            case let .loadResponse(.success(preferences)):
                state.errorMessage = nil
                state.isAnalyticsEnabled = preferences.isAnalyticsEnabled
                state.isCrashReportingEnabled = preferences.isCrashReportingEnabled
                state.isLoading = false
                state.themeMode = preferences.themeMode
                return .none

            case let .loadResponse(.failure(error)):
                state.errorMessage = error.message
                state.isLoading = false
                return .none

            case let .saveFailed(error):
                state.errorMessage = error.message
                return .none

            case .saveSucceeded:
                return .none

            case .settingsErrorDismissed:
                state.errorMessage = nil
                return .none

            case .task:
                state.errorMessage = nil
                state.isLoading = true
                return .run { send in
                    await send(
                        .loadResponse(
                            Result {
                                try await settingsClient.fetchPreferences()
                            }
                            .mapError(PFSettingsClientError.init)
                        )
                    )
                }

            case let .themeModeChanged(themeMode):
                state.themeMode = themeMode
                return save(state)
            }
        }
    }

    private func save(_ state: State) -> Effect<Action> {
        let preferences = PFSettingsPreferences(
            isAnalyticsEnabled: state.isAnalyticsEnabled,
            isCrashReportingEnabled: state.isCrashReportingEnabled,
            themeMode: state.themeMode
        )
        return .run { send in
            do {
                try await settingsClient.savePreferences(preferences)
                await send(.saveSucceeded)
            } catch {
                await send(.saveFailed(PFSettingsClientError(error)))
            }
        }
    }
}

struct PFSettingsPreferences: Equatable, Sendable {
    var isAnalyticsEnabled: Bool
    var isCrashReportingEnabled: Bool
    var themeMode: PFThemeMode = .system
}

enum PFThemeMode: String, CaseIterable, Equatable, Identifiable, Sendable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String {
        rawValue
    }
}
