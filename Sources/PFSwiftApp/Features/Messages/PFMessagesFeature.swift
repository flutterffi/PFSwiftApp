import ComposableArchitecture

@Reducer
struct PFMessagesFeature {
    @ObservableState
    struct State: Equatable {
        var threads: [PFMessageThread] = [
            PFMessageThread(title: "Platform", preview: "Architecture baseline is ready."),
            PFMessageThread(title: "Release", preview: "Tag preparation is queued.")
        ]
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        EmptyReducer()
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
