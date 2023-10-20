//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import PixelfedKit

@Model final public class StatusData {
    public var id: String
    public var accountAvatar: URL?
    public var accountDisplayName: String?
    public var accountId: String
    public var accountUsername: String
    public var applicationName: String?
    public var applicationWebsite: URL?
    public var bookmarked: Bool
    public var content: String
    public var createdAt: String
    public var favourited: Bool
    public var favouritesCount: Int32
    public var inReplyToAccount: String?
    public var inReplyToId: String?
    public var muted: Bool
    public var pinned: Bool
    public var reblogged: Bool
    public var reblogsCount: Int32
    public var repliesCount: Int32
    public var sensitive: Bool
    public var spoilerText: String?
    public var uri: String?
    public var url: URL?
    public var visibility: String
    @Relationship(deleteRule: .cascade, inverse: \AttachmentData.statusRelation)  public var attachmentsRelation: [AttachmentData]
    public var pixelfedAccount: AccountData?

    public var rebloggedStatusId: String?
    public var rebloggedAccountAvatar: URL?
    public var rebloggedAccountDisplayName: String?
    public var rebloggedAccountId: String?
    public var rebloggedAccountUsername: String?
    
    init(
        accountAvatar: URL? = nil,
        accountDisplayName: String? = nil,
        accountId: String = "",
        accountUsername: String = "",
        applicationName: String? = nil,
        applicationWebsite: URL? = nil,
        bookmarked: Bool = false,
        content: String = "",
        createdAt: String = "",
        favourited: Bool = false,
        favouritesCount: Int32 = .zero,
        id: String = "",
        inReplyToAccount: String? = nil,
        inReplyToId: String? = nil,
        muted: Bool = false,
        pinned: Bool = false,
        reblogged: Bool = false,
        reblogsCount: Int32 = .zero,
        repliesCount: Int32 = .zero,
        sensitive: Bool = false,
        spoilerText: String? = nil,
        uri: String? = nil,
        url: URL? = nil,
        visibility: String = "",
        attachmentsRelation: [AttachmentData] = [],
        pixelfedAccount: AccountData? = nil,
        rebloggedStatusId: String? = nil,
        rebloggedAccountAvatar: URL? = nil,
        rebloggedAccountDisplayName: String? = nil,
        rebloggedAccountId: String? = nil,
        rebloggedAccountUsername: String? = nil
    ) {
        self.accountAvatar = accountAvatar
        self.accountDisplayName = accountDisplayName
        self.accountId = accountId
        self.accountUsername = accountUsername
        self.applicationName = applicationName
        self.applicationWebsite = applicationWebsite
        self.bookmarked = bookmarked
        self.content = content
        self.createdAt = createdAt
        self.favourited = favourited
        self.favouritesCount = favouritesCount
        self.id = id
        self.inReplyToAccount = inReplyToAccount
        self.inReplyToId = inReplyToId
        self.muted = muted
        self.pinned = pinned
        self.reblogged = reblogged
        self.reblogsCount = reblogsCount
        self.repliesCount = repliesCount
        self.sensitive = sensitive
        self.spoilerText = spoilerText
        self.uri = uri
        self.url = url
        self.visibility = visibility
        self.attachmentsRelation = attachmentsRelation
        self.pixelfedAccount = pixelfedAccount
        self.rebloggedStatusId = rebloggedStatusId
        self.rebloggedAccountAvatar = rebloggedAccountAvatar
        self.rebloggedAccountDisplayName = rebloggedAccountDisplayName
        self.rebloggedAccountId = rebloggedAccountId
        self.rebloggedAccountUsername = rebloggedAccountUsername
    }
}

extension StatusData: Identifiable {
}

extension StatusData {
    func attachments() -> [AttachmentData] {
        return self.attachmentsRelation.sorted(by: { lhs, rhs in
            lhs.order < rhs.order
        })
    }
}

extension StatusData {
    func copyFrom(_ status: Status) {
        if let reblog = status.reblog {
            self.copyFrom(reblog)

            self.id = status.id
            self.rebloggedStatusId = reblog.id

            self.rebloggedAccountAvatar = status.account.avatar
            self.rebloggedAccountDisplayName = status.account.displayName
            self.rebloggedAccountId = status.account.id
            self.rebloggedAccountUsername = status.account.acct
        } else {
            self.id = status.id
            self.createdAt = status.createdAt
            self.accountAvatar = status.account.avatar
            self.accountDisplayName = status.account.displayName
            self.accountId = status.account.id
            self.accountUsername = status.account.acct
            self.applicationName = status.application?.name
            self.applicationWebsite = status.application?.website
            self.bookmarked = status.bookmarked
            self.content = status.content.htmlValue
            self.favourited = status.favourited
            self.favouritesCount = Int32(status.favouritesCount)
            self.inReplyToAccount = status.inReplyToAccount
            self.inReplyToId = status.inReplyToId
            self.muted = status.muted
            self.pinned = status.pinned
            self.reblogged = status.reblogged
            self.reblogsCount = Int32(status.reblogsCount)
            self.repliesCount = Int32(status.repliesCount)
            self.sensitive = status.sensitive
            self.spoilerText = status.spoilerText
            self.uri = status.uri
            self.url = status.url
            self.visibility = status.visibility.rawValue
        }
    }

    func updateFrom(_ status: Status) {
        if let reblog = status.reblog {
            self.updateFrom(reblog)

            self.rebloggedAccountAvatar = status.account.avatar
            self.rebloggedAccountDisplayName = status.account.displayName
            self.rebloggedAccountId = status.account.id
            self.rebloggedAccountUsername = status.account.acct
        } else {
            self.accountAvatar = status.account.avatar
            self.accountDisplayName = status.account.displayName
            self.accountUsername = status.account.acct
            self.applicationName = status.application?.name
            self.applicationWebsite = status.application?.website
            self.bookmarked = status.bookmarked
            self.content = status.content.htmlValue
            self.favourited = status.favourited
            self.favouritesCount = Int32(status.favouritesCount)
            self.inReplyToAccount = status.inReplyToAccount
            self.inReplyToId = status.inReplyToId
            self.muted = status.muted
            self.pinned = status.pinned
            self.reblogged = status.reblogged
            self.reblogsCount = Int32(status.reblogsCount)
            self.repliesCount = Int32(status.repliesCount)
            self.sensitive = status.sensitive
            self.spoilerText = status.spoilerText
            self.uri = status.uri
            self.url = status.url
            self.visibility = status.visibility.rawValue
        }
    }
}

public extension StatusData {
    func getOrginalStatusId() -> String {
        return self.rebloggedStatusId ?? self.id
    }
}

extension StatusData {
    func isFaulty() -> Bool {
        return self.isDeleted // || self.isFault
    }
}
