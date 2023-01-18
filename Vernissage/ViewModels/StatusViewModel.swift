//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import MastodonKit

public class StatusViewModel {

    public let uniqueId: UUID
    public let id: EntityId
    public let content: Html
    
    public let uri: String?
    public let url: URL?
    public let account: Account
    public let inReplyToId: AccountId?
    public let inReplyToAccount: EntityId?
    public let reblog: Status?
    public let createdAt: String
    public let reblogsCount: Int
    public let favouritesCount: Int
    public let repliesCount: Int
    public let reblogged: Bool
    public let favourited: Bool
    public let sensitive: Bool
    public let bookmarked: Bool
    public let pinned: Bool
    public let muted: Bool
    public let spoilerText: String?
    public let visibility: Status.Visibility
    public let mediaAttachments: [AttachmentViewModel]
    public let card: Card?
    public let mentions: [Mention]
    public let tags: [Tag]
    public let application: Application?
    public let place: Place?
    
    public init(
        id: EntityId,
        content: Html,
        uri: String,
        account: Account,
        application: Application,
        url: URL? = nil,
        inReplyToId: AccountId? = nil,
        inReplyToAccount: EntityId? = nil,
        reblog: Status? = nil,
        createdAt: String? = nil,
        reblogsCount: Int = 0,
        favouritesCount: Int = 0,
        repliesCount: Int = 0,
        reblogged: Bool = false,
        favourited: Bool = false,
        sensitive: Bool = false,
        bookmarked: Bool = false,
        pinned: Bool = false,
        muted: Bool = false,
        spoilerText: String? = nil,
        visibility: Status.Visibility = Status.Visibility.pub,
        mediaAttachments: [AttachmentViewModel] = [],
        card: Card? = nil,
        mentions: [Mention] = [],
        tags: [Tag] = [],
        place: Place? = nil
    ) {
        self.uniqueId = UUID()
        self.id = id
        self.content = content
        self.uri = uri
        self.url = url
        self.account = account
        self.application = application
        self.inReplyToId = inReplyToId
        self.inReplyToAccount = inReplyToAccount
        self.reblog = reblog
        self.createdAt = createdAt ?? Date().formatted(.iso8601)
        self.reblogsCount = reblogsCount
        self.favouritesCount = favouritesCount
        self.repliesCount = repliesCount
        self.reblogged = reblogged
        self.favourited = favourited
        self.sensitive = sensitive
        self.bookmarked = bookmarked
        self.pinned = pinned
        self.muted = muted
        self.spoilerText = spoilerText
        self.visibility = visibility
        self.mediaAttachments = mediaAttachments
        self.card = card
        self.mentions = mentions
        self.tags = tags
        self.place = place
    }
    
    init(status: Status) {
        self.uniqueId = UUID()
        self.id = status.id
        self.content = status.content
        self.uri = status.uri
        self.url = status.url
        self.account = status.account
        self.inReplyToId = status.inReplyToId
        self.inReplyToAccount = status.inReplyToAccount
        self.reblog = status.reblog
        self.createdAt = status.createdAt
        self.reblogsCount = status.reblogsCount
        self.favouritesCount = status.favouritesCount
        self.repliesCount = status.repliesCount
        self.reblogged = status.reblogged
        self.favourited = status.favourited
        self.sensitive = status.sensitive
        self.bookmarked = status.bookmarked
        self.pinned = status.pinned
        self.muted = status.muted
        self.spoilerText = status.spoilerText
        self.visibility = status.visibility
        self.card = status.card
        self.mentions = status.mentions
        self.tags = status.tags
        self.application = status.application
        self.place = status.place
        
        var mediaAttachments: [AttachmentViewModel] = []
        for item in status.mediaAttachments {
            mediaAttachments.append(AttachmentViewModel(attachment: item))
        }
        
        self.mediaAttachments = mediaAttachments
    }
}

public extension StatusViewModel {
    func getImageWidth() -> Int32? {
        if let width = (self.mediaAttachments.first?.meta as? ImageMetadata)?.original?.width {
            return Int32(width)
        } else {
            return nil
        }
    }
    
    func getImageHeight() -> Int32? {
        if let height = (self.mediaAttachments.first?.meta as? ImageMetadata)?.original?.height {
            return Int32(height)
        } else {
            return nil
        }
    }
}

public extension [Status] {
    func toStatusViewModel() -> [StatusViewModel] {
        self
            .sorted(by: { lhs, rhs in
                lhs.id < rhs.id
            })
            .map { status in
                StatusViewModel(status: status)
            }
    }
}
