import ComposableArchitecture
import Foundation

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
        return PFMessageClient(
            fetchThreads: {
                @Dependency(\.apiClient) var apiClient
                let response = try await apiClient.send(
                    PFMessageEndpoint.list,
                    as: [PFMessageThreadResponse].self
                )
                return response.map(\.messageThread)
            },
            saveThreads: { threads in
                @Dependency(\.apiClient) var apiClient
                _ = try await apiClient.send(
                    PFMessageEndpoint.save(threads.map(PFMessageThreadRequest.init(messageThread:))),
                    as: PFEmptyResponse.self
                )
            }
        )
    }()

    static let previewValue: PFMessageClient = {
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

private enum PFMessageEndpoint {
    static let list = PFAPIEndpoint(path: "messages/threads")

    static func save(_ threads: [PFMessageThreadRequest]) throws -> PFAPIEndpoint {
        let body = try PFAPIJSONCoding.encode(threads)
        return PFAPIEndpoint(
            path: "messages/threads",
            method: .put,
            headers: ["Content-Type": "application/json"],
            body: body
        )
    }
}

private struct PFMessageThreadResponse: Decodable, Sendable {
    var id: String
    var title: String
    var preview: String
    var isUnread: Bool
    var isPinned: Bool

    var messageThread: PFMessageThread {
        PFMessageThread(
            id: id,
            title: title,
            preview: preview,
            isUnread: isUnread,
            isPinned: isPinned
        )
    }
}

private struct PFMessageThreadRequest: Encodable, Sendable {
    var id: String
    var title: String
    var preview: String
    var isUnread: Bool
    var isPinned: Bool

    init(messageThread: PFMessageThread) {
        self.id = messageThread.id
        self.title = messageThread.title
        self.preview = messageThread.preview
        self.isUnread = messageThread.isUnread
        self.isPinned = messageThread.isPinned
    }
}
