//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

/// Mastodon 'Trends'.
extension Client {
    public class Trends: BaseClient {
        public func statuses(range: Mastodon.PixelfedTrends.TrendRange) async throws -> [Status] {
            return try await mastodonClient.statusesTrends(range: range)
        }
    }
}
