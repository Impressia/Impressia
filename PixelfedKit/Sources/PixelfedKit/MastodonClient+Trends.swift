//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension MastodonClientAuthenticated {

    func statusesTrends(range: Mastodon.Trends.TrendRange) async throws -> [Status] {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Trends.statuses(range, nil, nil),
            withBearerToken: token
        )
        
        return try await downloadJson([Status].self, request: request)
    }
}
