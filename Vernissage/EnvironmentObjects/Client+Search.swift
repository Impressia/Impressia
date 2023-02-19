//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import PixelfedKit

/// Pixelfed 'Search'.
extension Client {
    public class Search: BaseClient {
        public func search(query: String, resultsType: Pixelfed.Search.ResultsType) async throws -> SearchResults? {
            return try await pixelfedClient.search(query: query, type: resultsType)
        }
    }
}
