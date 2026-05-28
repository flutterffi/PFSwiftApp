import Foundation

enum PFAPIError: Error, Equatable, Sendable {
    case decoding(String)
    case invalidResponse
    case invalidURL
    case statusCode(Int, Data)
    case transport(String)

    var message: String {
        switch self {
        case let .decoding(message):
            return message
        case .invalidResponse:
            return "Invalid response."
        case .invalidURL:
            return "Invalid URL."
        case let .statusCode(statusCode, _):
            return "Request failed with status code \(statusCode)."
        case let .transport(message):
            return message
        }
    }
}
