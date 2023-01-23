//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public extension MastodonClientAuthenticated {

    func search(query: String, type: Mastodon.Search.ResultsType) async throws -> SearchResults {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Search.search(query, type, false),
            withBearerToken: token
        )
        
        return try await downloadJson(SearchResults.self, request: request)
    }
}
