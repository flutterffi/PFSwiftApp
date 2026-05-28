import ComposableArchitecture
import Foundation

struct PFTaskClient: Sendable {
    var fetchTasks: @Sendable () async throws -> [PFTaskItem]
    var saveTasks: @Sendable ([PFTaskItem]) async throws -> Void
}

struct PFTaskClientError: Error, Equatable, Sendable {
    var message: String

    init(_ error: Error) {
        self.message = error.localizedDescription
    }

    init(message: String) {
        self.message = message
    }
}

extension PFTaskClient: DependencyKey {
    static let liveValue: PFTaskClient = {
        return PFTaskClient(
            fetchTasks: {
                @Dependency(\.apiClient) var apiClient
                let response = try await apiClient.send(PFTaskEndpoint.list, as: [PFTaskResponse].self)
                return response.map(\.taskItem)
            },
            saveTasks: { tasks in
                @Dependency(\.apiClient) var apiClient
                _ = try await apiClient.send(
                    PFTaskEndpoint.save(tasks.map(PFTaskRequest.init(taskItem:))),
                    as: PFEmptyResponse.self
                )
            }
        )
    }()

    static let previewValue: PFTaskClient = {
        let storage = PFTaskStorage()
        return PFTaskClient(
            fetchTasks: {
                await storage.fetchTasks()
            },
            saveTasks: { tasks in
                await storage.saveTasks(tasks)
            }
        )
    }()

    static let testValue = PFTaskClient(
        fetchTasks: {
            reportIssue("PFTaskClient.fetchTasks is unimplemented")
            return []
        },
        saveTasks: { _ in
            reportIssue("PFTaskClient.saveTasks is unimplemented")
        }
    )
}

extension DependencyValues {
    var taskClient: PFTaskClient {
        get { self[PFTaskClient.self] }
        set { self[PFTaskClient.self] = newValue }
    }
}

private actor PFTaskStorage {
    private var tasks: [PFTaskItem]

    init(tasks: [PFTaskItem] = PFTaskItem.defaults) {
        self.tasks = tasks
    }

    func fetchTasks() -> [PFTaskItem] {
        tasks
    }

    func saveTasks(_ tasks: [PFTaskItem]) {
        self.tasks = tasks
    }
}

private enum PFTaskEndpoint {
    static let list = PFAPIEndpoint(path: "tasks")

    static func save(_ tasks: [PFTaskRequest]) throws -> PFAPIEndpoint {
        let body = try PFAPIJSONCoding.encode(tasks)
        return PFAPIEndpoint(
            path: "tasks",
            method: .put,
            headers: ["Content-Type": "application/json"],
            body: body
        )
    }
}

private struct PFTaskResponse: Decodable, Sendable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var priority: PFTaskPriority
    var dueDate: PFTaskDueDate

    var taskItem: PFTaskItem {
        PFTaskItem(
            id: id,
            title: title,
            isCompleted: isCompleted,
            priority: priority,
            dueDate: dueDate
        )
    }
}

private struct PFTaskRequest: Encodable, Sendable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var priority: PFTaskPriority
    var dueDate: PFTaskDueDate

    init(taskItem: PFTaskItem) {
        self.id = taskItem.id
        self.title = taskItem.title
        self.isCompleted = taskItem.isCompleted
        self.priority = taskItem.priority
        self.dueDate = taskItem.dueDate
    }
}

private struct PFEmptyResponse: Decodable, Sendable {}
