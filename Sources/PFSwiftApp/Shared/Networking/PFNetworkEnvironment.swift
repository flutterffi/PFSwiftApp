import Foundation

struct PFNetworkEnvironment: Equatable, Sendable {
    var baseURL: URL
    var defaultHeaders: [String: String]
    var timeoutInterval: TimeInterval

    init(
        baseURL: URL,
        defaultHeaders: [String: String] = [:],
        timeoutInterval: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeoutInterval = timeoutInterval
    }

    static let development = PFNetworkEnvironment(
        baseURL: URL(string: "https://api.dev.pfswiftapp.example")!,
        defaultHeaders: ["Accept": "application/json"]
    )

    static let staging = PFNetworkEnvironment(
        baseURL: URL(string: "https://api.staging.pfswiftapp.example")!,
        defaultHeaders: ["Accept": "application/json"]
    )

    static let production = PFNetworkEnvironment(
        baseURL: URL(string: "https://api.pfswiftapp.example")!,
        defaultHeaders: ["Accept": "application/json"]
    )
}
