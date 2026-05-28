import ComposableArchitecture

struct PFMessagesFeature: Reducer {
    struct State: Equatable {
        var threads: [PFMessageThread] = [
            PFMessageThread(title: "Platform", preview: "Architecture baseline is ready."),
            PFMessageThread(title: "Release", preview: "Tag preparation is queued.")
        ]
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
    }
}

struct PFMessageThread: Equatable, Identifiable {
    let id: String
    var title: String
    var preview: String

    init(id: String? = nil, title: String, preview: String) {
        self.id = id ?? title
        self.title = title
        self.preview = preview
    }
}
