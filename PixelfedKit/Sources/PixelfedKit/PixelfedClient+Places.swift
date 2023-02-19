//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public extension PixelfedClientAuthenticated {

    func places(query: String) async throws -> [Place] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Places.search(query),
            withBearerToken: token
        )
        
        return try await downloadJson([Place].self, request: request)
    }
}
