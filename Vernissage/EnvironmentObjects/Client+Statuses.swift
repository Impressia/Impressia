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

        func favourite(statusId: String) async throws -> Status? {
            return try await pixelfedClient.favourite(statusId: statusId)
        }

        func unfavourite(statusId: String) async throws -> Status? {
            return try await pixelfedClient.unfavourite(statusId: statusId)
        }

        func pin(statusId: String) async throws -> Status? {
            return try await pixelfedClient.pin(statusId: statusId)
        }

        func unpin(statusId: String) async throws -> Status? {
            return try await pixelfedClient.unpin(statusId: statusId)
        }

        func boost(statusId: String) async throws -> Status? {
            return try await pixelfedClient.boost(statusId: statusId)
        }

        func unboost(statusId: String) async throws -> Status? {
            return try await pixelfedClient.unboost(statusId: statusId)
        }

        func bookmark(statusId: String) async throws -> Status? {
            return try await pixelfedClient.bookmark(statusId: statusId)
        }

        func unbookmark(statusId: String) async throws -> Status? {
            return try await pixelfedClient.unbookmark(statusId: statusId)
        }

        func new(status: Pixelfed.Statuses.Components) async throws -> Status? {
            return try await pixelfedClient.new(statusComponents: status)
        }

        func delete(statusId: String) async throws {
            try await pixelfedClient.delete(statusId: statusId)
        }

        func comments(to statusId: String) async throws -> [CommentModel] {
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
