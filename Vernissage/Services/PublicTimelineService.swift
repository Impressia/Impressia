//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import MastodonKit

public class PublicTimelineService {
    public static let shared = PublicTimelineService()
    private init() { }
    
    public func getStatuses(accountData: AccountData?,
                            local: Bool,
                            remote: Bool,
                            maxId: String? = nil,
                            sinceId: String? = nil,
                            minId: String? = nil,
                            limit: Int = 40) async throws -> [Status] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.getPublicTimeline(local: local, remote: remote, onlyMedia: true, maxId: maxId, sinceId: sinceId, minId: minId, limit: limit)
    }
}
