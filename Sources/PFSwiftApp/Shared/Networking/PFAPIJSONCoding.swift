import Foundation

enum PFAPIJSONCoding {
    static func encode<Value: Encodable & Sendable>(_ value: Value) throws -> Data {
        do {
            return try makeEncoder().encode(value)
        } catch {
            throw PFAPIError.encoding(error.localizedDescription)
        }
    }

    static func decode<Value: Decodable & Sendable>(
        _ type: Value.Type,
        from data: Data
    ) throws -> Value {
        do {
            return try makeDecoder().decode(type, from: data)
        } catch {
            throw PFAPIError.decoding(error.localizedDescription)
        }
    }

    private static func makeEncoder() -> JSONEncoder {
        JSONEncoder()
    }

    private static func makeDecoder() -> JSONDecoder {
        JSONDecoder()
    }
}
