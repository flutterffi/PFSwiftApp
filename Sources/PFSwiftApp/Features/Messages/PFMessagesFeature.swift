import ComposableArchitecture

@Reducer
struct PFMessagesFeature {
    @Dependency(\.messageClient) var messageClient

    @ObservableState
    struct State: Equatable {
        var errorMessage: String?
        var isLoading = false
        var selectedThreadID: PFMessageThread.ID?
        var threads: IdentifiedArrayOf<PFMessageThread> = IdentifiedArray(uniqueElements: PFMessageThread.defaults)

        var unreadThreadCount: Int {
            threads.filter(\.isUnread).count
        }

        var pinnedThreadCount: Int {
            threads.filter(\.isPinned).count
        }

        var visibleThreads: IdentifiedArrayOf<PFMessageThread> {
            IdentifiedArray(
                uniqueElements: threads.sorted {
                    if $0.isPinned != $1.isPinned {
                        return $0.isPinned && !$1.isPinned
                    }
                    if $0.isUnread != $1.isUnread {
                        return $0.isUnread && !$1.isUnread
                    }
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            )
        }
    }

    enum Action: Equatable {
        case loadResponse(Result<[PFMessageThread], PFMessageClientError>)
        case markAllReadButtonTapped
        case messageErrorDismissed
        case pinToggled(PFMessageThread.ID)
        case saveFailed(PFMessageClientError)
        case saveSucceeded
        case task
        case threadTapped(PFMessageThread.ID)
        case unreadToggled(PFMessageThread.ID)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .loadResponse(.success(threads)):
                state.errorMessage = nil
                state.isLoading = false
                state.threads = IdentifiedArray(uniqueElements: threads)
                return .none

            case let .loadResponse(.failure(error)):
                state.errorMessage = error.message
                state.isLoading = false
                return .none

            case .markAllReadButtonTapped:
                for id in state.threads.ids {
                    state.threads[id: id]?.isUnread = false
                }
                return save(state.threads)

            case .messageErrorDismissed:
                state.errorMessage = nil
                return .none

            case let .pinToggled(id):
                state.threads[id: id]?.isPinned.toggle()
                return save(state.threads)

            case let .saveFailed(error):
                state.errorMessage = error.message
                return .none

            case .saveSucceeded:
                return .none

            case .task:
                state.errorMessage = nil
                state.isLoading = true
                return .run { send in
                    await send(
                        .loadResponse(
                            Result {
                                try await messageClient.fetchThreads()
                            }
                            .mapError(PFMessageClientError.init)
                        )
                    )
                }

            case let .threadTapped(id):
                state.selectedThreadID = id
                state.threads[id: id]?.isUnread = false
                return save(state.threads)

            case let .unreadToggled(id):
                state.threads[id: id]?.isUnread.toggle()
                return save(state.threads)
            }
        }
    }

    private func save(_ threads: IdentifiedArrayOf<PFMessageThread>) -> Effect<Action> {
        let threads = Array(threads)
        return .run { send in
            do {
                try await messageClient.saveThreads(threads)
                await send(.saveSucceeded)
            } catch {
                await send(.saveFailed(PFMessageClientError(error)))
            }
        }
    }
}

struct PFMessageThread: Equatable, Identifiable {
    let id: String
    var title: String
    var preview: String
    var isUnread: Bool
    var isPinned: Bool

    init(id: String? = nil, title: String, preview: String, isUnread: Bool = false, isPinned: Bool = false) {
        self.id = id ?? title
        self.title = title
        self.preview = preview
        self.isUnread = isUnread
        self.isPinned = isPinned
    }

    static let defaults = [
        PFMessageThread(title: "Platform", preview: "Architecture baseline is ready.", isUnread: false, isPinned: true),
        PFMessageThread(title: "Release", preview: "Tag preparation is queued.", isUnread: true)
    ]
}
