//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

public class StatusModel: ObservableObject {
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
    public let commentsDisabled: Bool

    public let reblogStatus: Status?

    @Published public var favourited: Bool
    @Published public var mediaAttachments: [AttachmentModel]

    public init(status: Status) {

        // If status has been rebloged we are saving orginal status here.
        let orginalStatus = status.reblog ?? status

        self.id = status.id
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
        self.commentsDisabled = orginalStatus.commentsDisabled

        var mediaAttachments: [AttachmentModel] = []
        for item in orginalStatus.getAllImageMediaAttachments() {
            mediaAttachments.append(AttachmentModel(attachment: item))
        }

        self.mediaAttachments = mediaAttachments

        if status.reblog != nil {
            self.reblogStatus = status
        } else {
            self.reblogStatus = nil
        }
    }
}

public extension StatusModel {
    func getImageWidth() -> Int32? {
        let highestImage = self.mediaAttachments.getHighestImage()
        if let width = (highestImage?.meta as? ImageMetadata)?.original?.width {
            return Int32(width)
        } else {
            return nil
        }
    }

    func getImageHeight() -> Int32? {
        let highestImage = self.mediaAttachments.getHighestImage()
        if let height = (highestImage?.meta as? ImageMetadata)?.original?.height {
            return Int32(height)
        } else {
            return nil
        }
    }
}

extension StatusModel: Equatable {
    public static func == (lhs: StatusModel, rhs: StatusModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension StatusModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.id)
    }
}

extension StatusModel: Identifiable {
}

public extension [StatusModel] {
    func getAllImagesUrls() -> [URL] {
        var urls: [URL] = []

        for status in self {
            urls.append(contentsOf: status.mediaAttachments.map({ $0.url }))
        }

        return urls
    }
}

public extension [Status] {
    func toStatusModels() -> [StatusModel] {
        self
            .sorted(by: { lhs, rhs in
                lhs.id < rhs.id
            })
            .map { status in
                StatusModel(status: status)
            }
    }
}
