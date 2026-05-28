import ComposableArchitecture
import Foundation

struct PFAPIClient: Sendable {
    var sendData: @Sendable (PFAPIEndpoint) async throws -> Data
    var send: @Sendable (PFAPIEndpoint, any Decodable.Type) async throws -> Any

    func send<Response: Decodable & Sendable>(
        _ endpoint: PFAPIEndpoint,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        guard let response = try await send(endpoint, responseType) as? Response else {
            throw PFAPIError.decoding("Decoded response type mismatch.")
        }
        return response
    }
}

extension PFAPIClient {
    static func live(
        environment: PFNetworkEnvironment = .development,
        session: URLSession = .shared,
        decoder: PFAPIResponseDecoder = PFAPIResponseDecoder()
    ) -> PFAPIClient {
        let builder = PFAPIRequestBuilder(environment: environment)
        let sendData: @Sendable (PFAPIEndpoint) async throws -> Data = { endpoint in
            let request = try builder.request(for: endpoint)
            let data: Data
            let response: URLResponse
            do {
                (data, response) = try await session.data(for: request)
            } catch {
                throw PFAPIError.transport(error.localizedDescription)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PFAPIError.invalidResponse
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw PFAPIError.statusCode(httpResponse.statusCode, data)
            }
            return data
        }
        return PFAPIClient(
            sendData: sendData,
            send: { endpoint, responseType in
                let data = try await sendData(endpoint)
                return try decoder.decode(responseType, from: data)
            }
        )
    }
}

extension PFAPIClient: DependencyKey {
    static let liveValue = PFAPIClient.live()

    static let testValue = PFAPIClient(
        sendData: { _ in
            reportIssue("PFAPIClient.sendData is unimplemented")
            return Data()
        },
        send: { _, _ in
            reportIssue("PFAPIClient.send is unimplemented")
            return Data()
        }
    )
}

extension DependencyValues {
    var apiClient: PFAPIClient {
        get { self[PFAPIClient.self] }
        set { self[PFAPIClient.self] = newValue }
    }
}
