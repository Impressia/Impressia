//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import PixelfedKit

/// Mastodon 'Notifications'.
extension Client {
    public class Notifications: BaseClient {
        public func notifications(maxId: MaxId? = nil,
                                  sinceId: SinceId? = nil,
                                  minId: MinId? = nil,
                                  limit: Int? = nil
        ) async throws -> Linkable<[PixelfedKit.Notification]> {
            return try await mastodonClient.notifications(maxId: maxId, sinceId: sinceId, minId: minId, limit: limit)
        }
    }
}
