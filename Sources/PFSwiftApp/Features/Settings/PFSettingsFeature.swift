import ComposableArchitecture

struct PFSettingsFeature: Reducer {
    struct State: Equatable {
        var isAnalyticsEnabled = true
        var isCrashReportingEnabled = true
    }

    enum Action: Equatable {
        case analyticsChanged(Bool)
        case crashReportingChanged(Bool)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .analyticsChanged(isEnabled):
                state.isAnalyticsEnabled = isEnabled
                return .none

            case let .crashReportingChanged(isEnabled):
                state.isCrashReportingEnabled = isEnabled
                return .none
            }
        }
    }
}
