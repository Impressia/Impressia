//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension MastodonClientAuthenticated {

    func statusesTrends(range: Mastodon.PixelfedTrends.TrendRange) async throws -> [Status] {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.PixelfedTrends.statuses(range),
            withBearerToken: token
        )
        
        return try await downloadJson([Status].self, request: request)
    }
}
