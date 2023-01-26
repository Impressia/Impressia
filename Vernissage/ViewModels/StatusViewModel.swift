//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import MastodonKit

public class StatusViewModel: ObservableObject {

    public let uniqueId: UUID
    public let id: EntityId
    public let content: Html
    
    public let uri: String?
    public let url: URL?
    public let account: Account
    public let inReplyToId: EntityId?
    public let inReplyToAccount: EntityId?
    
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
    public let card: PreviewCard?
    public let mentions: [Mention]
    public let tags: [Tag]
    public let application: BaseApplication?
    public let place: Place?
    
    public let reblogStatus: Status?
    
    @Published public var mediaAttachments: [AttachmentViewModel]
    
    public init(
        id: EntityId,
        content: Html,
        uri: String,
        account: Account,
        application: BaseApplication,
        url: URL? = nil,
        inReplyToId: EntityId? = nil,
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
        card: PreviewCard? = nil,
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
        self.reblogStatus = nil
    }
    
    init(status: Status) {
        
        // If status has been rebloged we are saving orginal status here.
        let orginalStatus = status.reblog ?? status
        
        self.uniqueId = UUID()
        self.id = orginalStatus.id
        self.content = orginalStatus.content
        self.uri = orginalStatus.uri
        self.url = orginalStatus.url
        self.account = orginalStatus.account
        self.inReplyToId = orginalStatus.inReplyToId
        self.inReplyToAccount = orginalStatus.inReplyToAccount
        self.createdAt = orginalStatus.createdAt
        self.reblogsCount = orginalStatus.reblogsCount
        self.favouritesCount = orginalStatus.favouritesCount
        self.repliesCount = orginalStatus.repliesCount
        self.reblogged = orginalStatus.reblogged
        self.favourited = orginalStatus.favourited
        self.sensitive = orginalStatus.sensitive
        self.bookmarked = orginalStatus.bookmarked
        self.pinned = orginalStatus.pinned
        self.muted = orginalStatus.muted
        self.spoilerText = orginalStatus.spoilerText
        self.visibility = orginalStatus.visibility
        self.card = orginalStatus.card
        self.mentions = orginalStatus.mentions
        self.tags = orginalStatus.tags
        self.application = orginalStatus.application
        self.place = orginalStatus.place
        
        var mediaAttachments: [AttachmentViewModel] = []
        for item in orginalStatus.mediaAttachments {
            mediaAttachments.append(AttachmentViewModel(attachment: item))
        }
        
        self.mediaAttachments = mediaAttachments
        
        if status.reblog != nil {
            self.reblogStatus = status
        } else {
            self.reblogStatus = nil
        }
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
