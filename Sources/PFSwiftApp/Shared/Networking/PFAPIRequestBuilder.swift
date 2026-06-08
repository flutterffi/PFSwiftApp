import Foundation

struct PFAPIRequestBuilder: Sendable {
    var environment: PFNetworkEnvironment

    func request(
        for endpoint: PFAPIEndpoint,
        additionalHeaders: [String: String] = [:]
    ) throws -> URLRequest {
        let baseURL = environment.baseURL
        let url = baseURL.appending(path: endpoint.path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw PFAPIError.invalidURL
        }
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        guard let resolvedURL = components.url else {
            throw PFAPIError.invalidURL
        }

        var request = URLRequest(url: resolvedURL, timeoutInterval: environment.timeoutInterval)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        for (key, value) in environment.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        for (key, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}
