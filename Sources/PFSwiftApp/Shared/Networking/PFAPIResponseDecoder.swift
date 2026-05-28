import Foundation

struct PFAPIResponseDecoder: Sendable {
    var decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func decode<Response: Decodable & Sendable>(
        _ type: Response.Type,
        from data: Data
    ) throws -> Response {
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw PFAPIError.decoding(error.localizedDescription)
        }
    }
}
