//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public class AccountModel: ObservableObject, Identifiable {
    public let id: String
    public let accessToken: String?
    public let refreshToken: String?
    public let acct: String
    public let avatar: URL?
    public let clientId: String
    public let clientSecret: String
    public let clientVapidKey: String
    public let createdAt: String
    public let displayName: String?
    public let followersCount: Int32
    public let followingCount: Int32
    public let header: URL?
    public let locked: Bool
    public let note: String?
    public let serverUrl: URL
    public let statusesCount: Int32
    public let url: URL?
    public let username: String
    public let lastSeenStatusId: String?

    @Published public var avatarData: Data?

    init(accountData: AccountData) {
        self.accessToken = accountData.accessToken
        self.refreshToken = accountData.refreshToken
        self.acct = accountData.acct
        self.avatar = accountData.avatar
        self.avatarData = accountData.avatarData
        self.clientId = accountData.clientId
        self.clientSecret = accountData.clientSecret
        self.clientVapidKey = accountData.clientVapidKey
        self.createdAt = accountData.createdAt
        self.displayName = accountData.displayName
        self.followersCount = accountData.followersCount
        self.followingCount = accountData.followingCount
        self.header = accountData.header
        self.id = accountData.id
        self.locked = accountData.locked
        self.note = accountData.note
        self.serverUrl = accountData.serverUrl
        self.statusesCount = accountData.statusesCount
        self.url = accountData.url
        self.username = accountData.username
        self.lastSeenStatusId = accountData.lastSeenStatusId
    }
}

extension AccountModel: Equatable {
    public static func == (lhs: AccountModel, rhs: AccountModel) -> Bool {
        lhs.id == rhs.id
    }
}
