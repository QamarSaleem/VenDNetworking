

public protocol RequestManagerProtocol {
    @available(iOS 13.0.0, *)
    func perform<T: Decodable>(_ request: RequestProtocol) async throws -> T
}

public final class RequestManager: RequestManagerProtocol {
  let apiManager: APIManagerProtocol
  let parser: DataParserProtocol
  let accessTokenManager: AccessTokenManagerProtocol

    public init(
    apiManager: APIManagerProtocol = APIManager(),
    parser: DataParserProtocol = DataParser(),
    accessTokenManager: AccessTokenManagerProtocol = AccessTokenManager()
  ) {
    self.apiManager = apiManager
    self.parser = parser
    self.accessTokenManager = accessTokenManager
  }

    @available(iOS 13.0.0, *)
    public func requestAccessToken() async throws -> String {
    if accessTokenManager.isTokenValid() {
      return accessTokenManager.fetchToken()
    }

        let data = try await apiManager.requestToken()
        let token: APIToken = try parser.parse(data: data)
        try accessTokenManager.refreshWith(apiToken: token)
            return token.bearerAccessToken
    }

    @available(iOS 13.0.0, *)
    public func perform<T: Decodable>(_ request: RequestProtocol) async throws -> T {
        let authToken = try await requestAccessToken()
        let data = try await apiManager.perform(request, authToken: authToken)
        let decoded: T = try parser.parse(data: data)
    return decoded
  }
}
