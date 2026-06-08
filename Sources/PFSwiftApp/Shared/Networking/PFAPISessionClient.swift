import ComposableArchitecture

struct PFAPISessionClient: Sendable {
    var accessToken: @Sendable () async -> String?
}

extension PFAPISessionClient: DependencyKey {
    static let liveValue = PFAPISessionClient(
        accessToken: {
            nil
        }
    )

    static let testValue = PFAPISessionClient(
        accessToken: {
            nil
        }
    )
}

extension DependencyValues {
    var apiSession: PFAPISessionClient {
        get { self[PFAPISessionClient.self] }
        set { self[PFAPISessionClient.self] = newValue }
    }
}
