//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents a keyword that, if matched, should cause the filter action to be taken.
public struct FilterKeyword: Codable {

    /// The ID of the FilterKeyword in the database.
    public let id: EntityId

    /// The phrase to be matched against.
    public let keyword: String

    /// Should the filter consider word boundaries? See [implementation guidelines for filters](https://docs.joinmastodon.org/api/guidelines/#filters).
    public let wholeWord: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case keyword
        case wholeWord = "whole_word"
    }
}
