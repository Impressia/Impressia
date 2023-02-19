//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the relationship between accounts, such as following / blocking / muting / etc.
public struct Relationship: Codable {
    
    /// The account ID.
    public let id: EntityId
    
    /// Are you following this user?
    public let following: Bool
    
    /// Are you followed by this user?
    public let followedBy: Bool
    
    /// Are you blocking this user?
    public let blocking: Bool
    
    /// Is this user blocking you?
    public let blockedBy: Bool
    
    /// Are you muting this user?
    public let muting: Bool
    
    /// Are you muting notifications from this user?
    public let mutingNotifications: Bool
    
    /// Do you have a pending follow request for this user?
    public let requested: Bool
    
    /// Are you receiving this user’s boosts in your home timeline?
    public let showingReblogs: Bool
    
    /// Have you enabled notifications for this user?
    public let notifying: Bool
    
    /// Are you blocking this user’s domain?
    public let domainBlocking: Bool
    
    /// Are you featuring this user on your profile?
    public let endorsed: Bool

    /// Which languages are you following from this user? Array of String (ISO 639-1 language two-letter code).
    public let languages: [String]?
    
    /// This user’s profile bio.
    public let note: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case following
        case followedBy = "followed_by"
        case blocking
        case blockedBy = "blocked_by"
        case muting
        case mutingNotifications = "muting_notifications"
        case requested
        case showingReblogs = "showing_reblogs"
        case notifying
        case domainBlocking = "domain_blocking"
        case endorsed
        case languages
        case note
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.following = (try? container.decode(Bool.self, forKey: .following)) ?? false
        self.followedBy = (try? container.decode(Bool.self, forKey: .followedBy)) ?? false
        self.blocking = (try? container.decode(Bool.self, forKey: .blocking)) ?? false
        self.blockedBy = (try? container.decode(Bool.self, forKey: .blockedBy)) ?? false
        self.muting = (try? container.decode(Bool.self, forKey: .muting)) ?? false
        self.mutingNotifications = (try? container.decode(Bool.self, forKey: .mutingNotifications)) ?? false
        self.requested = (try? container.decode(Bool.self, forKey: .requested)) ?? false
        self.showingReblogs = (try? container.decode(Bool.self, forKey: .showingReblogs)) ?? false
        self.notifying = (try? container.decode(Bool.self, forKey: .notifying)) ?? false
        self.domainBlocking = (try? container.decode(Bool.self, forKey: .domainBlocking)) ?? false
        self.endorsed = (try? container.decode(Bool.self, forKey: .endorsed)) ?? false
        self.languages = try? container.decodeIfPresent([String].self, forKey: .languages)
        self.note = try? container.decodeIfPresent(String.self, forKey: .note)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(following, forKey: .following)
        try container.encode(followedBy, forKey: .followedBy)
        try container.encode(blocking, forKey: .blocking)
        try container.encode(blockedBy, forKey: .blockedBy)
        try container.encode(muting, forKey: .muting)
        try container.encode(mutingNotifications, forKey: .mutingNotifications)
        try container.encode(requested, forKey: .requested)
        try container.encode(showingReblogs, forKey: .showingReblogs)
        try container.encode(notifying, forKey: .notifying)
        try container.encode(domainBlocking, forKey: .domainBlocking)
        try container.encode(endorsed, forKey: .endorsed)
        
        if let languages {
            try container.encode(languages, forKey: .languages)
        }
        
        if let note {
            try container.encode(note, forKey: .note)
        }
    }
}
