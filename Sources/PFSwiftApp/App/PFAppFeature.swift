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
                state.dashboard = Self.dashboardState(
                    tasks: state.tasks,
                    messages: state.messages,
                    settings: state.settings
                )
                return .none

            case .settings:
                state.dashboard = Self.dashboardState(
                    tasks: state.tasks,
                    messages: state.messages,
                    settings: state.settings
                )
                return .none

            case .messages:
                state.dashboard = Self.dashboardState(
                    tasks: state.tasks,
                    messages: state.messages,
                    settings: state.settings
                )
                return .none

            case .dashboard:
                return .none
            }
        }
    }

    private static func dashboardState(
        tasks: PFTasksFeature.State,
        messages: PFMessagesFeature.State = PFMessagesFeature.State(),
        settings: PFSettingsFeature.State
    ) -> PFDashboardFeature.State {
        PFDashboardFeature.State(
            taskSummaryItems: [
                PFDashboardSummary(title: "Open Tasks", value: "\(tasks.activeTaskCount)"),
                PFDashboardSummary(title: "High Priority", value: "\(tasks.highPriorityTaskCount)"),
                PFDashboardSummary(title: "Due Soon", value: "\(tasks.dueSoonTaskCount)"),
                PFDashboardSummary(title: "Done Tasks", value: "\(tasks.completedTaskCount)"),
                PFDashboardSummary(title: "Total Tasks", value: "\(tasks.tasks.count)")
            ],
            messageSummaryItems: [
                PFDashboardSummary(title: "Unread Messages", value: "\(messages.unreadThreadCount)"),
                PFDashboardSummary(title: "Total Messages", value: "\(messages.threads.count)")
            ],
            systemSummaryItems: [
                PFDashboardSummary(title: "Theme", value: settings.themeMode.rawValue),
                PFDashboardSummary(title: "Analytics", value: settings.isAnalyticsEnabled ? "On" : "Off"),
                PFDashboardSummary(title: "Crash Reporting", value: settings.isCrashReportingEnabled ? "On" : "Off")
            ]
        )
    }
}
