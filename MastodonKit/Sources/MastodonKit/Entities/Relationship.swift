import Foundation

public struct Relationship: Codable {
    public let id: String
    public let following: Bool
    public let followedBy: Bool
    public let blocking: Bool
    public let blockedBy: Bool
    public let muting: Bool
    public let mutingNotifications: Bool
    public let requested: Bool
    public let showingReblogs: Bool
    public let notifying: Bool
    public let domainBlocking: Bool
    public let endorsed: Bool

    
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
    }
}
