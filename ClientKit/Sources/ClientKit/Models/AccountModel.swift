//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

@Observable public class AccountModel: Identifiable {
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
    public let lastSeenNotificationId: String?
    
    public var avatarData: Data?

    public init(id: String,
                accessToken: String?,
                refreshToken: String?,
                acct: String,
                avatar: URL?,
                clientId: String,
                clientSecret: String,
                clientVapidKey: String,
                createdAt: String,
                displayName: String?,
                followersCount: Int32,
                followingCount: Int32,
                header: URL?,
                locked: Bool,
                note: String?,
                serverUrl: URL,
                statusesCount: Int32,
                url: URL?,
                username: String,
                lastSeenStatusId: String?,
                lastSeenNotificationId: String?,
                avatarData: Data? = nil) {
        self.id = id
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.acct = acct
        self.avatar = avatar
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.clientVapidKey = clientVapidKey
        self.createdAt = createdAt
        self.displayName = displayName
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.header = header
        self.locked = locked
        self.note = note
        self.serverUrl = serverUrl
        self.statusesCount = statusesCount
        self.url = url
        self.username = username
        self.lastSeenStatusId = lastSeenStatusId
        self.avatarData = avatarData
        self.lastSeenNotificationId = lastSeenNotificationId
    }
}

extension AccountModel: Equatable {
    public static func == (lhs: AccountModel, rhs: AccountModel) -> Bool {
        lhs.id == rhs.id
    }
}
