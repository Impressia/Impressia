//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import MastodonKit

/// Mastodon 'Places'.
extension Client {
    public class Places: BaseClient {
        public func search(query: String) async throws -> [Place] {
            return try await mastodonClient.places(query: query)
        }
    }
}
