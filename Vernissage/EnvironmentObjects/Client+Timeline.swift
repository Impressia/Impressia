//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

/// Mastodon 'Timeline'.
extension Client {
    public class PublicTimeline: BaseClient {
        public func getStatuses(local: Bool,
                                remote: Bool,
                                maxId: String? = nil,
                                sinceId: String? = nil,
                                minId: String? = nil,
                                limit: Int = 40) async throws -> [Status] {
            return try await mastodonClient.getPublicTimeline(local: local,
                                                              remote: remote,
                                                              onlyMedia: true,
                                                              maxId: maxId,
                                                              sinceId: sinceId,
                                                              minId: minId,
                                                              limit: limit)
        }
        
        public func getTagStatuses(tag: String,
                                   local: Bool,
                                   remote: Bool,
                                   maxId: String? = nil,
                                   sinceId: String? = nil,
                                   minId: String? = nil,
                                   limit: Int = 40) async throws -> [Status] {
            return try await mastodonClient.getTagTimeline(tag: tag,
                                                           local: local,
                                                           remote: remote,
                                                           onlyMedia: true,
                                                           maxId: maxId,
                                                           sinceId: sinceId,
                                                           minId: minId,
                                                           limit: limit)
        }
    }
}
