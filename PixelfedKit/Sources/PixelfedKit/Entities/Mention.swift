//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Mentions of users within the status content.
public struct Mention: Codable {

    /// The account ID of the mentioned user.
    public let id: String

    /// The location of the mentioned user’s profile.
    public let url: String

    /// The username of the mentioned user.
    public let username: String

    /// The webfinger acct: URI of the mentioned user. Equivalent to username for local users, or username@domain for remote users.
    public let acct: String
}
