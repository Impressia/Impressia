//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents a status posted by an account.
public class Status: Codable {
    public enum Visibility: String, Codable {
        case pub = "public"
        case unlisted = "unlisted"
        case priv = "private"
        case direct = "direct"
    }

    /// ID of the status in the database.
    public let id: EntityId

    /// HTML-encoded status content.
    public let content: Html
    
    /// URI of the status used for federation.
    public let uri: String?
    
    /// A link to the status’s HTML representation.
    public let url: URL?

    /// The account that authored this status.
    public let account: Account

    /// ID of the status being replied to.
    public let inReplyToId: EntityId?
    
    /// ID of the account that authored the status being replied to.
    public let inReplyToAccount: EntityId?
    
    /// The status being reblogged.
    public let reblog: Status?
    
    /// The date when this status was created. String (ISO 8601 Datetime).
    public let createdAt: String

    /// How many boosts this status has received.
    public let reblogsCount: Int
    
    /// How many favourites this status has received.
    public let favouritesCount: Int
    
    /// How many replies this status has received.
    public let repliesCount: Int

    /// If the current token has an authorized user: Have you boosted this status?
    public let reblogged: Bool
    
    /// If the current token has an authorized user: Have you favourited this status?
    public let favourited: Bool
    
    /// Is this status marked as sensitive content?
    public let sensitive: Bool

    /// If the current token has an authorized user: Have you bookmarked this status?
    public let bookmarked: Bool
    
    /// If the current token has an authorized user: Have you pinned this status? Only appears if the status is pinnable.
    public let pinned: Bool
    
    /// If the current token has an authorized user: Have you muted notifications for this status’s conversation?
    public let muted: Bool
    
    /// Subject or summary line, below which status content is collapsed until expanded.
    public let spoilerText: String?
    
    /// Visibility of this status.
    public let visibility: Visibility

    /// Media that is attached to this status.
    public let mediaAttachments: [MediaAttachment]

    /// Preview card for links included within status content.
    public let card: PreviewCard?
    
    /// Mentions of users within the status content.
    public let mentions: [Mention]

    /// Hashtags used within the status content.
    public let tags: [Tag]
    
    /// The application used to post this status.
    public let application: BaseApplication?

    /// Place where photo has been taken (specific for Pixelfed).
    public let place: Place?
    
    /// Custom emoji to be used when rendering status content.
    public let emojis: [CustomEmoji]?

    /// The poll attached to the status.
    public let poll: Poll?

    /// Primary language of this status. NULLABLE String (ISO 639 Part 1 two-letter language code) or null.
    public let language: String?
    
    /// Plain-text source of a status. Returned instead of content when status is deleted, so the user may redraft from the source text
    /// without the client having to reverse-engineer the original text from the HTML content.
    public let text: String?
    
    /// Timestamp of when the status was last edited. NULLABLE String (ISO 8601 Datetime).
    public let editedAt: String?
    
    /// If the current token has an authorized user: The filter and keywords that matched this status.
    public let filtered: FilterResult?
    
    /// Information about enabled/disabled comments.
    public let commentsDisabled: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case uri
        case url
        case account
        case inReplyToId = "in_reply_to_id"
        case inReplyToAccount = "in_reply_to_account_id"
        case reblog
        case content
        case createdAt = "created_at"
        case reblogsCount = "reblogs_count"
        case favouritesCount = "favourites_count"
        case repliesCount = "replies_count"
        case reblogged
        case favourited
        case sensitive
        case bookmarked
        case pinned
        case muted
        case spoilerText = "spoiler_text"
        case visibility
        case mediaAttachments = "media_attachments"
        case card
        case mentions
        case tags
        case application
        case place
        case emojis
        case poll
        case language
        case text
        case editedAt = "edited_at"
        case filtered
        case commentsDisabled = "comments_disabled"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(EntityId.self, forKey: .id)
        self.uri = try container.decode(String.self, forKey: .uri)
        self.url = try? container.decode(URL.self, forKey: .url)
        self.account = try container.decode(Account.self, forKey: .account)
        self.content = (try? container.decode(Html.self, forKey: .content)) ?? Html("")
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.inReplyToId = try? container.decode(EntityId.self, forKey: .inReplyToId)
        self.inReplyToAccount = try? container.decode(EntityId.self, forKey: .inReplyToAccount)
        self.reblog = try? container.decode(Status.self, forKey: .reblog)
        self.spoilerText = try? container.decode(String.self, forKey: .spoilerText)
        self.reblogsCount = (try? container.decode(Int.self, forKey: .reblogsCount)) ?? 0
        self.repliesCount = (try? container.decode(Int.self, forKey: .repliesCount)) ?? 0
        self.favouritesCount = (try? container.decode(Int.self, forKey: .favouritesCount)) ?? 0
        self.reblogged = (try? container.decode(Bool.self, forKey: .reblogged)) ?? false
        self.favourited = (try? container.decode(Bool.self, forKey: .favourited)) ?? false
        self.sensitive = (try? container.decode(Bool.self, forKey: .sensitive)) ?? false
        self.bookmarked = (try? container.decode(Bool.self, forKey: .bookmarked)) ?? false
        self.pinned = (try? container.decode(Bool.self, forKey: .pinned)) ?? false
        self.muted = (try? container.decode(Bool.self, forKey: .muted)) ?? false
        self.visibility = try container.decode(Visibility.self, forKey: .visibility)
        self.mediaAttachments = (try? container.decode([MediaAttachment].self, forKey: .mediaAttachments)) ?? []
        self.card = try? container.decode(PreviewCard.self, forKey: .card)
        self.mentions = (try? container.decode([Mention].self, forKey: .mentions)) ?? []
        self.tags = (try? container.decode([Tag].self, forKey: .tags)) ?? []
        self.application = try? container.decode(BaseApplication.self, forKey: .application)
        self.place = try? container.decodeIfPresent(Place.self, forKey: .place)
        self.emojis = try? container.decodeIfPresent([CustomEmoji].self, forKey: .emojis)
        self.poll = try? container.decodeIfPresent(Poll.self, forKey: .poll)
        self.language = try? container.decodeIfPresent(String.self, forKey: .language)
        self.text = try? container.decodeIfPresent(String.self, forKey: .text)
        self.editedAt = try? container.decodeIfPresent(String.self, forKey: .editedAt)
        self.filtered = try? container.decodeIfPresent(FilterResult.self, forKey: .filtered)
        self.commentsDisabled = (try? container.decode(Bool.self, forKey: .commentsDisabled)) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(uri, forKey: .uri)
        
        if let url {
            try container.encode(url, forKey: .url)
        }
        
        try container.encode(account, forKey: .account)
        try container.encode(content, forKey: .content)
        try container.encode(createdAt, forKey: .createdAt)
        
        if let inReplyToId {
            try container.encode(inReplyToId, forKey: .inReplyToId)
        }
        
        if let inReplyToAccount {
            try container.encode(inReplyToAccount, forKey: .inReplyToAccount)
        }
        
        if let reblog {
            try container.encode(reblog, forKey: .reblog)
        }
        
        if let spoilerText {
            try container.encode(spoilerText, forKey: .spoilerText)
        }
        
        try container.encode(reblogsCount, forKey: .reblogsCount)
        try container.encode(favouritesCount, forKey: .favouritesCount)
        try container.encode(repliesCount, forKey: .repliesCount)
        try container.encode(reblogged, forKey: .reblogged)
        try container.encode(favourited, forKey: .favourited)
        try container.encode(bookmarked, forKey: .bookmarked)
        try container.encode(pinned, forKey: .pinned)
        try container.encode(muted, forKey: .muted)
        try container.encode(sensitive, forKey: .sensitive)
        try container.encode(visibility, forKey: .visibility)
        try container.encode(mediaAttachments, forKey: .mediaAttachments)
        
        if let card {
            try container.encode(card, forKey: .card)
        }
        
        try container.encode(mentions, forKey: .mentions)
        try container.encode(tags, forKey: .tags)
        
        if let application {
            try container.encode(application, forKey: .application)
        }
        
        if let place {
            try container.encode(place, forKey: .place)
        }
        
        if let emojis {
            try container.encode(emojis, forKey: .emojis)
        }
        
        if let poll {
            try container.encode(poll, forKey: .poll)
        }
        
        if let language {
            try container.encode(language, forKey: .language)
        }
        
        if let text {
            try container.encode(text, forKey: .text)
        }
        
        if let editedAt {
            try container.encode(editedAt, forKey: .editedAt)
        }
        
        if let filtered {
            try container.encode(filtered, forKey: .filtered)
        }
        
        try container.encodeIfPresent(commentsDisabled, forKey: .commentsDisabled)
    }
}
