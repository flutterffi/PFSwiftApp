import ComposableArchitecture

enum PFTab: String, CaseIterable, Equatable {
    case dashboard
    case tasks
    case messages
    case settings
}

struct PFAppFeature: Reducer {
    struct State: Equatable {
        var selectedTab: PFTab = .dashboard
        var dashboard = PFDashboardFeature.State()
        var tasks = PFTasksFeature.State()
        var messages = PFMessagesFeature.State()
        var settings = PFSettingsFeature.State()
    }

    enum Action: Equatable {
        case selectedTabChanged(PFTab)
        case dashboard(PFDashboardFeature.Action)
        case tasks(PFTasksFeature.Action)
        case messages(PFMessagesFeature.Action)
        case settings(PFSettingsFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.dashboard, action: /Action.dashboard) {
            PFDashboardFeature()
        }
        Scope(state: \.tasks, action: /Action.tasks) {
            PFTasksFeature()
        }
        Scope(state: \.messages, action: /Action.messages) {
            PFMessagesFeature()
        }
        Scope(state: \.settings, action: /Action.settings) {
            PFSettingsFeature()
        }
        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none

            case .dashboard, .tasks, .messages, .settings:
                return .none
            }
        }
    }
}
