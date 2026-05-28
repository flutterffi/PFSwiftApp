@testable import PFSwiftApp
import XCTest

final class PFAPIClientTests: XCTestCase {
    override func tearDown() {
        PFURLProtocolStub.reset()
        super.tearDown()
    }

    func testRequestBuilderBuildsRequest() throws {
        let environment = PFNetworkEnvironment(
            baseURL: URL(string: "https://api.example.com")!,
            defaultHeaders: ["Accept": "application/json"],
            timeoutInterval: 12
        )
        let builder = PFAPIRequestBuilder(environment: environment)
        let request = try builder.request(
            for: PFAPIEndpoint(
                path: "tasks",
                method: .post,
                queryItems: [URLQueryItem(name: "page", value: "1")],
                headers: ["Authorization": "Bearer token"],
                body: Data("{}".utf8)
            )
        )

        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/tasks?page=1")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
        XCTAssertEqual(request.timeoutInterval, 12)
        XCTAssertEqual(request.httpBody, Data("{}".utf8))
    }

    func testSendDecodesSuccessfulResponse() async throws {
        let session = URLSession(configuration: .pfStubbed)
        let client = PFAPIClient.live(
            environment: PFNetworkEnvironment(baseURL: URL(string: "https://api.example.com")!),
            session: session
        )
        PFURLProtocolStub.response = (
            HTTPURLResponse(
                url: URL(string: "https://api.example.com/tasks")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!,
            Data(#"{"id":"task-1","title":"Loaded"}"#.utf8)
        )

        let response = try await client.send(PFStubResponseEndpoint.tasks, as: PFStubResponse.self)

        XCTAssertEqual(response, PFStubResponse(id: "task-1", title: "Loaded"))
        XCTAssertEqual(PFURLProtocolStub.lastRequest?.url?.absoluteString, "https://api.example.com/tasks")
    }

    func testSendThrowsStatusCodeError() async {
        let session = URLSession(configuration: .pfStubbed)
        let client = PFAPIClient.live(
            environment: PFNetworkEnvironment(baseURL: URL(string: "https://api.example.com")!),
            session: session
        )
        PFURLProtocolStub.response = (
            HTTPURLResponse(
                url: URL(string: "https://api.example.com/tasks")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!,
            Data("failure".utf8)
        )

        do {
            _ = try await client.send(PFStubResponseEndpoint.tasks, as: PFStubResponse.self)
            XCTFail("Expected status code failure.")
        } catch let error as PFAPIError {
            XCTAssertEqual(error, .statusCode(500, Data("failure".utf8)))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testJSONCodingMapsDecodingErrors() {
        XCTAssertThrowsError(
            try PFAPIJSONCoding.decode(PFStubResponse.self, from: Data(#"{"id":1}"#.utf8))
        ) { error in
            XCTAssertTrue(error is PFAPIError)
            XCTAssertTrue((error as? PFAPIError)?.message.isEmpty == false)
        }
    }

    func testJSONCodingMapsEncodingErrors() {
        XCTAssertThrowsError(
            try PFAPIJSONCoding.encode(PFInvalidEncodable())
        ) { error in
            XCTAssertTrue(error is PFAPIError)
            XCTAssertTrue((error as? PFAPIError)?.message.isEmpty == false)
        }
    }
}

private enum PFStubResponseEndpoint {
    static let tasks = PFAPIEndpoint(path: "tasks")
}

private struct PFStubResponse: Decodable, Equatable, Sendable {
    var id: String
    var title: String
}

private struct PFInvalidEncodable: Encodable, Sendable {
    func encode(to encoder: Encoder) throws {
        throw PFInvalidEncodingError()
    }
}

private struct PFInvalidEncodingError: Error {}

private final class PFURLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var lastRequest: URLRequest?
    nonisolated(unsafe) static var response: (HTTPURLResponse, Data)?

    static func reset() {
        lastRequest = nil
        response = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lastRequest = request
        guard let response = Self.response else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        client?.urlProtocol(self, didReceive: response.0, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: response.1)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private extension URLSessionConfiguration {
    static var pfStubbed: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [PFURLProtocolStub.self]
        return configuration
    }
}
