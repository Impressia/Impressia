//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation

public extension PixelfedClientAuthenticated {

    func search(query: String, type: Pixelfed.Search.ResultsType, limit: Int = 20, page: Int = 1) async throws -> SearchResults {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Search.search(query, type, false, nil, nil, nil, limit, page),
            withBearerToken: token
        )
        
        return try await downloadJson(SearchResults.self, request: request)
    }
}
