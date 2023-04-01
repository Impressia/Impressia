//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents a poll attached to a status.
public struct Poll: Codable {

    /// The ID of the poll in the database.
    public let id: EntityId

    /// When the poll ends. NULLABLE String (ISO 8601 Datetime), or null if the poll does not end.
    public let expiresAt: String?

    /// Is the poll currently expired?
    public let expired: Bool

    /// Does the poll allow multiple-choice answers?
    public let multiple: Bool

    /// How many votes have been received.
    public let votesCount: Int

    /// How many unique accounts have voted on a multiple-choice poll.
    public let votersCount: Int?

    /// Possible answers for the poll.
    public let options: [PollOption]

    /// Custom emoji to be used for rendering poll options.
    public let emojis: [CustomEmoji]?

    /// When called with a user token, has the authorized user voted?
    public let voted: Bool?

    /// When called with a user token, which options has the authorized user chosen? Contains an array of index values for options.
    public let ownVotes: [Int]?

    private enum CodingKeys: String, CodingKey {
        case id
        case expiresAt = "expires_at"
        case expired
        case multiple
        case votesCount = "votes_count"
        case votersCount = "voters_count"
        case options
        case emojis
        case voted
        case ownVotes = "own_votes"
    }
}
