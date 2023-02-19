//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension PixelfedClientAuthenticated {
    func status(statusId: EntityId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.status(statusId),
            withBearerToken: token)
        
        return try await downloadJson(Status.self, request: request)
    }
    
    func favouritedBy(for statusId: String, page: Int = 1) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.favouritedBy(statusId, nil, nil, nil, nil, page),
            withBearerToken: token
        )

        return try await downloadJson([Account].self, request: request)
    }
    
    func rebloggedBy(for statusId: String, page: Int = 1) async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.rebloggedBy(statusId, nil, nil, nil, nil, page),
            withBearerToken: token
        )
        
        return try await downloadJson([Account].self, request: request)
    }
}
