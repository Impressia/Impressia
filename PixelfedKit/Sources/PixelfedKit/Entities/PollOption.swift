//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Possible answers for the poll.
public struct PollOption: Codable {

    /// The text value of the poll option.
    public let title: String

    /// he total number of received votes for this option. NULLABLE Integer, or null if results are not published yet.
    public let votesCount: Int?

    private enum CodingKeys: String, CodingKey {
        case title
        case votesCount = "votes_count"
    }
}
