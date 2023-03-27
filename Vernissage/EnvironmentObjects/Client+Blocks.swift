//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import PixelfedKit

/// Pixelfed 'Trends'.
extension Client {
    public class Blocks: BaseClient {
        public func blocks(maxId: String? = nil,
                           sinceId: String? = nil,
                           minId: String? = nil,
                           limit: Int = 10,
                           page: Int? = nil) async throws -> [Account] {
            return try await pixelfedClient.blocks(maxId: maxId, sinceId: sinceId, minId: minId, limit: limit, page: page)
        }
    }
}
