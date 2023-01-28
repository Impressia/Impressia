//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import MastodonKit

public class NotificationService {
    public static let shared = NotificationService()
    private init() { }
    
    public func notifications(for accountData: AccountData?,
                              maxId: MaxId? = nil,
                              sinceId: SinceId? = nil,
                              minId: MinId? = nil,
                              limit: Int? = nil
    ) async throws -> Linkable<[MastodonKit.Notification]> {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return Linkable<[MastodonKit.Notification]>(data: [])
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.notifications(maxId: maxId, sinceId: sinceId, minId: minId, limit: limit)
    }
}
