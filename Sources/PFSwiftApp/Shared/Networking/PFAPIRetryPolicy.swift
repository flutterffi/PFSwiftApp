struct PFAPIRetryPolicy: Equatable, Sendable {
    var retryCount: Int

    init(retryCount: Int = 1) {
        self.retryCount = max(0, retryCount)
    }

    static let disabled = PFAPIRetryPolicy(retryCount: 0)
    static let standard = PFAPIRetryPolicy(retryCount: 1)

    func shouldRetry(endpoint: PFAPIEndpoint, error: PFAPIError, attempt: Int) -> Bool {
        guard attempt <= retryCount, endpoint.method.isRetryable else {
            return false
        }

        switch error {
        case let .statusCode(statusCode, _):
            return statusCode == 408 || statusCode == 429 || (500..<600).contains(statusCode)
        case .transport:
            return true
        case .decoding, .encoding, .invalidResponse, .invalidURL:
            return false
        }
    }
}

private extension PFHTTPMethod {
    var isRetryable: Bool {
        self == .get
    }
}
