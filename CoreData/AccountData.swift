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
    public var accessToken: String?
    public var refreshToken: String?
    public var acct: String
    public var avatar: URL?
    public var avatarData: Data?
    public var clientId: String
    public var clientSecret: String
    public var clientVapidKey: String
    public var createdAt: String
    public var displayName: String?
    public var followersCount: Int32
    public var followingCount: Int32
    public var header: URL?
    public var locked: Bool
    public var note: String?
    public var serverUrl: URL
    public var statusesCount: Int32
    public var url: URL?
    public var username: String
    
    /// Last status seen on home timeline by the user.
    public var lastSeenStatusId: String?
    
    /// Last status loaded on home timeline.
    public var lastLoadedStatusId: String?
    
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
                                        avatarData: self.avatarData)
        return accountModel
    }
}
