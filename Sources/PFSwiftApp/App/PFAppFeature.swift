import ComposableArchitecture

enum PFTab: String, CaseIterable, Equatable {
    case dashboard
    case tasks
    case messages
    case settings
}

@Reducer
struct PFAppFeature {
    @ObservableState
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
        Scope(state: \.dashboard, action: \.dashboard) {
            PFDashboardFeature()
        }
        Scope(state: \.tasks, action: \.tasks) {
            PFTasksFeature()
        }
        Scope(state: \.messages, action: \.messages) {
            PFMessagesFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            PFSettingsFeature()
        }
        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none

            case .tasks:
                state.dashboard.summaryItems = [
                    PFDashboardSummary(title: "Open Tasks", value: "\(state.tasks.activeTaskCount)"),
                    PFDashboardSummary(title: "Done Tasks", value: "\(state.tasks.completedTaskCount)"),
                    PFDashboardSummary(title: "Total Tasks", value: "\(state.tasks.tasks.count)")
                ]
                return .none

            case .dashboard, .messages, .settings:
                return .none
            }
        }
    }
}
