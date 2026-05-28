import ComposableArchitecture

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
