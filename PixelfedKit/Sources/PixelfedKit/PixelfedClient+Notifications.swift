//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public extension PixelfedClientAuthenticated {
    func notifications(maxId: MaxId? = nil,
                          sinceId: SinceId? = nil,
                          minId: MinId? = nil,
                          limit: Int? = nil
    ) async throws -> Linkable<[Notification]> {
        let request = try Self.request(for: baseURL,
                                       target: Pixelfed.Notifications.notifications(maxId, sinceId, minId, limit),
                                       withBearerToken: token)

        return try await downloadJsonWithLink([Notification].self, request: request)
    }
}
