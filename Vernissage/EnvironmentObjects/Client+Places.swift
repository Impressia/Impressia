//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

/// Pixelfed 'Places'.
extension Client {
    public class Places: BaseClient {
        public func search(query: String) async throws -> [Place] {
            return try await pixelfedClient.places(query: query)
        }
    }
}
