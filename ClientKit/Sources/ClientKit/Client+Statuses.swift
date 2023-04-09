//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

extension Client {
    public class Statuses: BaseClient {

        public func status(withId statusId: String) async throws -> Status {
            return try await pixelfedClient.status(statusId: statusId)
        }

        public func favourite(statusId: String) async throws -> Status? {
            return try await pixelfedClient.favourite(statusId: statusId)
        }

        public func unfavourite(statusId: String) async throws -> Status? {
            return try await pixelfedClient.unfavourite(statusId: statusId)
        }

        public func pin(statusId: String) async throws -> Status? {
            return try await pixelfedClient.pin(statusId: statusId)
        }

        public func unpin(statusId: String) async throws -> Status? {
            return try await pixelfedClient.unpin(statusId: statusId)
        }

        public func boost(statusId: String) async throws -> Status? {
            return try await pixelfedClient.boost(statusId: statusId)
        }

        public func unboost(statusId: String) async throws -> Status? {
            return try await pixelfedClient.unboost(statusId: statusId)
        }

        public func bookmark(statusId: String) async throws -> Status? {
            return try await pixelfedClient.bookmark(statusId: statusId)
        }

        public func unbookmark(statusId: String) async throws -> Status? {
            return try await pixelfedClient.unbookmark(statusId: statusId)
        }

        public func new(status: Pixelfed.Statuses.Components) async throws -> Status? {
            return try await pixelfedClient.new(statusComponents: status)
        }

        public func delete(statusId: String) async throws {
            try await pixelfedClient.delete(statusId: statusId)
        }

        public func comments(to statusId: String) async throws -> [CommentModel] {
            var commentViewModels: [CommentModel] = []

            try await self.getCommentDescendants(to: statusId, showDivider: true, to: &commentViewModels)

            return commentViewModels
        }

        public func favouritedBy(statusId: String, limit: Int, page: Int) async throws -> [Account] {
            return try await pixelfedClient.favouritedBy(for: statusId, limit: limit, page: page)
        }

        public func rebloggedBy(statusId: String, limit: Int, page: Int) async throws -> [Account] {
            return try await pixelfedClient.rebloggedBy(for: statusId, limit: limit, page: page)
        }

        private func getCommentDescendants(to statusId: String, showDivider: Bool, to commentViewModels: inout [CommentModel]) async throws {
            let context = try await pixelfedClient.getContext(for: statusId)

            let descendants = context.descendants.toStatusModels()
            for status in descendants {
                commentViewModels.append(CommentModel(status: status, showDivider: showDivider))

                if status.repliesCount > 0 {
                    try await self.getCommentDescendants(to: status.id, showDivider: false, to: &commentViewModels)
                }
            }
        }
    }
}
