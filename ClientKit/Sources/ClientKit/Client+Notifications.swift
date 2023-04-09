//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

extension Client {
    public class Notifications: BaseClient {
        public func notifications(maxId: MaxId? = nil,
                                  sinceId: SinceId? = nil,
                                  minId: MinId? = nil,
                                  limit: Int? = nil
        ) async throws -> Linkable<[PixelfedKit.Notification]> {
            return try await pixelfedClient.notifications(maxId: maxId, sinceId: sinceId, minId: minId, limit: limit)
        }
    }
}
