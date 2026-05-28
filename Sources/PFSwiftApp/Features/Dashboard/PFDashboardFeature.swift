import ComposableArchitecture

@Reducer
struct PFDashboardFeature {
    @ObservableState
    struct State: Equatable {
        var title = "Operations"
        var taskSummaryItems: [PFDashboardSummary] = [
            PFDashboardSummary(title: "Open Tasks", value: "2"),
            PFDashboardSummary(title: "High Priority", value: "1"),
            PFDashboardSummary(title: "Done Tasks", value: "1"),
            PFDashboardSummary(title: "Total Tasks", value: "3")
        ]
        var messageSummaryItems: [PFDashboardSummary] = [
            PFDashboardSummary(title: "Unread Messages", value: "1"),
            PFDashboardSummary(title: "Total Messages", value: "2")
        ]
        var systemSummaryItems: [PFDashboardSummary] = [
            PFDashboardSummary(title: "Theme", value: "System"),
            PFDashboardSummary(title: "Analytics", value: "On"),
            PFDashboardSummary(title: "Crash Reporting", value: "On")
        ]
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

struct PFDashboardSummary: Equatable, Identifiable {
    let id: String
    var title: String
    var value: String

    init(id: String? = nil, title: String, value: String) {
        self.id = id ?? title
        self.title = title
        self.value = value
    }
}
