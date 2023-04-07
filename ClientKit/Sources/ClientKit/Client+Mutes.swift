//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

extension Client {
    public class Mutes: BaseClient {
        public func mutes(maxId: String? = nil,
                          sinceId: String? = nil,
                          minId: String? = nil,
                          limit: Int = 10,
                          page: Int? = nil) async throws -> [Account] {
            return try await pixelfedClient.mutes(maxId: maxId, sinceId: sinceId, minId: minId, limit: limit, page: page)
        }
    }
}
