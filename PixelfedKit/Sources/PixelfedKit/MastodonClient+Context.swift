//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public extension MastodonClientAuthenticated {
    func getContext(for statusId: String) async throws -> Context {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.context(statusId),
            withBearerToken: token
        )
        
        return try await downloadJson(Context.self, request: request)
    }
}
