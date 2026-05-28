import ComposableArchitecture
import Foundation

struct PFAPIClient: Sendable {
    var sendData: @Sendable (PFAPIEndpoint) async throws -> Data
    var responseDecoder: PFAPIResponseDecoder = PFAPIResponseDecoder()

    func send<Response: Decodable & Sendable>(
        _ endpoint: PFAPIEndpoint,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        let data = try await sendData(endpoint)
        return try responseDecoder.decode(responseType, from: data)
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
            responseDecoder: decoder
        )
    }
}

extension PFAPIClient: DependencyKey {
    static let liveValue = PFAPIClient.live()

    static let testValue = PFAPIClient(
        sendData: { _ in
            reportIssue("PFAPIClient.sendData is unimplemented")
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
