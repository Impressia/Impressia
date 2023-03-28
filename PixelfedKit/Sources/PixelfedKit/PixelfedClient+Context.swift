//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation

public extension PixelfedClientAuthenticated {
    func getContext(for statusId: String) async throws -> Context {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Statuses.context(statusId),
            withBearerToken: token
        )
        
        return try await downloadJson(Context.self, request: request)
    }
}
