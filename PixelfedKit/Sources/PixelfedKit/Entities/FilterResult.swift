//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents a filter whose keywords matched a given status.
public struct FilterResult: Codable {

    /// The filter that was matched.
    public let filter: Filter

    /// The keyword within the filter that was matched.
    public let keywordMatches: [String]?

    /// The status ID within the filter that was matched.
    public let statusMatches: [EntityId]?

    private enum CodingKeys: String, CodingKey {
        case filter
        case keywordMatches = "keyword_matches"
        case statusMatches = "status_matches"
    }
}
