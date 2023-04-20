//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

extension StatusData {
    func copyFrom(_ status: Status) {
        if let reblog = status.reblog {
            self.copyFrom(reblog)

            self.rebloggedStatusId = status.id
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
