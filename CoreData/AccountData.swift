//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import ClientKit

@Model final public class AccountData {
    @Attribute(.unique) public var id: String
    
    /// Access token to the server API.
    public var accessToken: String?
    
    /// Refresh token which can be used to download new access token.
    public var refreshToken: String?
    
    /// Full user  name (user name with server address).
    public var acct: String
    
    /// URL to user avatar.
    public var avatar: URL?
    
    /// Avatar downloaded from server (visible mainly in top navigation bar).
    @Attribute(.externalStorage) public var avatarData: Data?
    
    /// Id of OAuth client.
    public var clientId: String
    
    /// Secret of OAutch client.
    public var clientSecret: String
    
    /// Vapid key of OAuth client.
    public var clientVapidKey: String
    
    /// Date of creating user.
    public var createdAt: String
    
    /// Human readable user name.
    public var displayName: String?
    
    /// Number of followers.
    public var followersCount: Int32
    
    /// Number of following users.
    public var followingCount: Int32
    
    /// URL to header image visible on user profile.
    public var header: URL?
    
    /// User profile is locked.
    public var locked: Bool
    
    /// Description on user profile.
    public var note: String?
    
    /// Address to server.
    public var serverUrl: URL
    
    /// NUmber of statuses added by the user.
    public var statusesCount: Int32
    
    /// Url to user profile.
    public var url: URL?
    
    /// User name (without server address).
    public var username: String
    
    /// Last status seen on home timeline by the user.
    public var lastSeenStatusId: String?
    
    /// Last status loaded on home timeline.
    public var lastLoadedStatusId: String?
    
    /// JSON string with last objects loaded into home timeline.
    public var timelineCache: String?
    
    /// Last notification seen by the user.
    public var lastSeenNotificationId: String?
    
    @Relationship(deleteRule: .cascade, inverse: \ViewedStatus.pixelfedAccount) public var viewedStatuses: [ViewedStatus]
    @Relationship(deleteRule: .cascade, inverse: \AccountRelationship.pixelfedAccount) public var accountRelationships: [AccountRelationship]

    init(
        accessToken: String? = nil,
        refreshToken: String? = nil,
        acct: String = "",
        avatar: URL? = nil,
        avatarData: Data? = nil,
        clientId: String = "",
        clientSecret: String = "",
        clientVapidKey: String = "",
        createdAt: String = "",
        displayName: String? = nil,
        followersCount: Int32 = .zero,
        followingCount: Int32 = .zero,
        header: URL? = nil,
        id: String = "",
        locked: Bool = false,
        note: String? = nil,
        serverUrl: URL,
        statusesCount: Int32 = .zero,
        url: URL? = nil,
        username: String = "",
        viewedStatuses: [ViewedStatus] = [],
        accountRelationships: [AccountRelationship] = [],
        lastSeenStatusId: String? = nil
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.acct = acct
        self.avatar = avatar
        self.avatarData = avatarData
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.clientVapidKey = clientVapidKey
        self.createdAt = createdAt
        self.displayName = displayName
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.header = header
        self.id = id
        self.locked = locked
        self.note = note
        self.serverUrl = serverUrl
        self.statusesCount = statusesCount
        self.url = url
        self.username = username
        self.viewedStatuses = viewedStatuses
        self.accountRelationships = accountRelationships
        self.lastSeenStatusId = lastSeenStatusId
    }
}

extension AccountData: Identifiable {
}

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
                                        lastSeenNotificationId: self.lastSeenNotificationId,
                                        avatarData: self.avatarData)
        return accountModel
    }
}
