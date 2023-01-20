//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public struct Account: Codable {
    public let id: String
    public let username: String
    public let acct: String
    public let displayName: String?
    public let note: String?
    public let url: URL?
    public let avatar: URL?
    public let header: URL?
    public let locked: Bool
    public let createdAt: String
    public let followersCount: Int
    public let followingCount: Int
    public let statusesCount: Int
    public let emojis: [Emoji] = []
    
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case acct
        case locked
        case createdAt = "created_at"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case statusesCount = "statuses_count"
        case displayName = "display_name"
        case note
        case url
        case avatar
        case header
        case emojis
    }
}

extension Account {
    public var safeDisplayName: String {
        return self.displayName ?? self.acct
    }
    
    public var displayNameWithoutEmojis: String {
        var name = safeDisplayName
        for emoji in emojis {
            name = name.replacingOccurrences(of: ":\(emoji.shortcode):", with: "")
        }
        return name.split(separator: " ", omittingEmptySubsequences: true).joined(separator: " ")
    }
}
