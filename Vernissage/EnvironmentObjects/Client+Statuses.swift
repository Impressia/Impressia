//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import PixelfedKit

/// Mastodon 'Statuses'.
extension Client {
    public class Statuses: BaseClient {
        
        public func status(withId statusId: String) async throws -> Status {
            return try await mastodonClient.status(statusId: statusId)
        }
        
        func favourite(statusId: String) async throws -> Status? {
            return try await mastodonClient.favourite(statusId: statusId)
        }
        
        func unfavourite(statusId: String) async throws -> Status? {
            return try await mastodonClient.unfavourite(statusId: statusId)
        }
        
        func pin(statusId: String) async throws -> Status? {
            return try await mastodonClient.pin(statusId: statusId)
        }
        
        func unpin(statusId: String) async throws -> Status? {
            return try await mastodonClient.unpin(statusId: statusId)
        }
        
        func boost(statusId: String) async throws -> Status? {
            return try await mastodonClient.boost(statusId: statusId)
        }
        
        func unboost(statusId: String) async throws -> Status? {
            return try await mastodonClient.unboost(statusId: statusId)
        }
        
        func bookmark(statusId: String) async throws -> Status? {
            return try await mastodonClient.bookmark(statusId: statusId)
        }
        
        func unbookmark(statusId: String) async throws -> Status? {
            return try await mastodonClient.unbookmark(statusId: statusId)
        }
        
        func new(status: Mastodon.Statuses.Components) async throws -> Status? {
            return try await mastodonClient.new(statusComponents: status)
        }
        
        func delete(statusId: String) async throws {
            try await mastodonClient.delete(statusId: statusId)
        }
        
        func comments(to statusId: String) async throws -> [CommentModel] {
            var commentViewModels: [CommentModel] = []
            
            try await self.getCommentDescendants(to: statusId, showDivider: true, to: &commentViewModels)
            
            return commentViewModels
        }
        
        public func favouritedBy(statusId: String, page: Int) async throws -> [Account] {
            return try await mastodonClient.favouritedBy(for: statusId, page: page)
        }
        
        public func rebloggedBy(statusId: String, page: Int) async throws -> [Account] {
            return try await mastodonClient.rebloggedBy(for: statusId, page: page)
        }
        
        private func getCommentDescendants(to statusId: String, showDivider: Bool, to commentViewModels: inout [CommentModel]) async throws {
            let context = try await mastodonClient.getContext(for: statusId)
            
            let descendants = context.descendants.toStatusViewModel()
            for status in descendants {
                commentViewModels.append(CommentModel(status: status, showDivider: showDivider))
                
                if status.repliesCount > 0 {
                    try await self.getCommentDescendants(to: status.id, showDivider: false, to: &commentViewModels)
                }
            }
        }
    }
}
