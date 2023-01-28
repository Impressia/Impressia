//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

public class TrendsService {
    public static let shared = TrendsService()
    private init() { }
    
    public func statuses(for accountData: AccountData?,
                         range: Mastodon.PixelfedTrends.TrendRange) async throws -> [Status] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.statusesTrends(range: range)
    }
}
