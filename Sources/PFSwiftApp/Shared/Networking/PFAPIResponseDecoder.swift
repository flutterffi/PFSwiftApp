import Foundation

struct PFAPIResponseDecoder: Sendable {
    func decode<Response: Decodable & Sendable>(
        _ type: Response.Type,
        from data: Data
    ) throws -> Response {
        try PFAPIJSONCoding.decode(type, from: data)
    }
}
