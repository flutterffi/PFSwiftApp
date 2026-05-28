import ComposableArchitecture

@Reducer
struct PFMessagesFeature {
    @ObservableState
    struct State: Equatable {
        var selectedThreadID: PFMessageThread.ID?
        var threads: IdentifiedArrayOf<PFMessageThread> = [
            PFMessageThread(title: "Platform", preview: "Architecture baseline is ready.", isUnread: false),
            PFMessageThread(title: "Release", preview: "Tag preparation is queued.", isUnread: true)
        ]

        var unreadThreadCount: Int {
            threads.filter(\.isUnread).count
        }
    }

    enum Action: Equatable {
        case markAllReadButtonTapped
        case threadTapped(PFMessageThread.ID)
        case unreadToggled(PFMessageThread.ID)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .markAllReadButtonTapped:
                for id in state.threads.ids {
                    state.threads[id: id]?.isUnread = false
                }
                return .none

            case let .threadTapped(id):
                state.selectedThreadID = id
                state.threads[id: id]?.isUnread = false
                return .none

            case let .unreadToggled(id):
                state.threads[id: id]?.isUnread.toggle()
                return .none
            }
        }
    }
}

struct PFMessageThread: Equatable, Identifiable {
    let id: String
    var title: String
    var preview: String
    var isUnread: Bool

    init(id: String? = nil, title: String, preview: String, isUnread: Bool = false) {
        self.id = id ?? title
        self.title = title
        self.preview = preview
        self.isUnread = isUnread
    }
}
