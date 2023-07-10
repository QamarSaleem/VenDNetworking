

import Foundation

public protocol APIManagerProtocol {
    @available(iOS 13.0.0, *)
    func perform(_ request: RequestProtocol, authToken: String) async throws -> Data
    @available(iOS 13.0.0, *)
    func requestToken() async throws -> Data
}

public class APIManager: APIManagerProtocol {
  private let urlSession: URLSession

    public init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }

    @available(iOS 13.0.0, *)
    public func perform(_ request: RequestProtocol, authToken: String = "") async throws -> Data {
    let (data, response) = try await urlSession.data(for: request.createURLRequest(authToken: authToken))
    guard let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 200 else { throw NetworkError.invalidServerResponse }
    return data
  }

    @available(iOS 13.0.0, *)
    public func requestToken() async throws -> Data {
    try await perform(AuthTokenRequest.auth)
  }
}
