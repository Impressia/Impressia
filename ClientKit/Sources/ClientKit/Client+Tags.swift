//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

extension Client {
    public class Tags: BaseClient {
        public func get(tag: String) async throws -> Tag? {
            return try await pixelfedClient.tag(hashtag: tag)
        }

        public func follow(tag: String) async throws -> Tag? {
            return try await pixelfedClient.follow(hashtag: tag)
        }

        public func unfollow(tag: String) async throws -> Tag? {
            return try await pixelfedClient.unfollow(hashtag: tag)
        }
    }
}
