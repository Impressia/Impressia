import Foundation

public extension MastodonClientAuthenticated {
    func verifyCredentials() async throws -> Account {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Account.verifyCredentials,
            withBearerToken: token
        )
        
        return try await downloadJson(Account.self, request: request)
    }
}
