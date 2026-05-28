import ComposableArchitecture

struct PFMessageClient: Sendable {
    var fetchThreads: @Sendable () async throws -> [PFMessageThread]
    var saveThreads: @Sendable ([PFMessageThread]) async throws -> Void
}

struct PFMessageClientError: Error, Equatable, Sendable {
    var message: String

    init(_ error: Error) {
        self.message = error.localizedDescription
    }

    init(message: String) {
        self.message = message
    }
}

extension PFMessageClient: DependencyKey {
    static let liveValue: PFMessageClient = {
        let storage = PFMessageStorage()
        return PFMessageClient(
            fetchThreads: {
                await storage.fetchThreads()
            },
            saveThreads: { threads in
                await storage.saveThreads(threads)
            }
        )
    }()

    static let testValue = PFMessageClient(
        fetchThreads: {
            reportIssue("PFMessageClient.fetchThreads is unimplemented")
            return []
        },
        saveThreads: { _ in
            reportIssue("PFMessageClient.saveThreads is unimplemented")
        }
    )
}

extension DependencyValues {
    var messageClient: PFMessageClient {
        get { self[PFMessageClient.self] }
        set { self[PFMessageClient.self] = newValue }
    }
}

private actor PFMessageStorage {
    private var threads: [PFMessageThread]

    init(threads: [PFMessageThread] = PFMessageThread.defaults) {
        self.threads = threads
    }

    func fetchThreads() -> [PFMessageThread] {
        threads
    }

    func saveThreads(_ threads: [PFMessageThread]) {
        self.threads = threads
    }
}
