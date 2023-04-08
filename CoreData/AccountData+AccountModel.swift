//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import ClientKit

extension AccountData {
    func toAccountModel() -> AccountModel {
        let accountModel = AccountModel(id: self.id,
                                        accessToken: self.accessToken,
                                        refreshToken: self.refreshToken,
                                        acct: self.acct,
                                        avatar: self.avatar,
                                        clientId: self.clientId,
                                        clientSecret: self.clientSecret,
                                        clientVapidKey: self.clientVapidKey,
                                        createdAt: self.createdAt,
                                        displayName: self.displayName,
                                        followersCount: self.followersCount,
                                        followingCount: self.followingCount,
                                        header: self.header,
                                        locked: self.locked,
                                        note: self.note,
                                        serverUrl: self.serverUrl,
                                        statusesCount: self.statusesCount,
                                        url: self.url,
                                        username: self.username,
                                        lastSeenStatusId: self.lastSeenStatusId,
                                        avatarData: self.avatarData)
        return accountModel
    }
}
