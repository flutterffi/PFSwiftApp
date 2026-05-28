import ComposableArchitecture

struct PFDashboardFeature: Reducer {
    struct State: Equatable {
        var title = "Operations"
        var summaryItems: [PFDashboardSummary] = [
            PFDashboardSummary(title: "Open Tasks", value: "3"),
            PFDashboardSummary(title: "Messages", value: "2"),
            PFDashboardSummary(title: "Status", value: "Ready")
        ]
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
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
