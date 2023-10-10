//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData

extension AccountData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountData> {
        return NSFetchRequest<AccountData>(entityName: "AccountData")
    }

    @NSManaged public var accessToken: String?
    @NSManaged public var refreshToken: String?
    @NSManaged public var acct: String
    @NSManaged public var avatar: URL?
    @NSManaged public var avatarData: Data?
    @NSManaged public var clientId: String
    @NSManaged public var clientSecret: String
    @NSManaged public var clientVapidKey: String
    @NSManaged public var createdAt: String
    @NSManaged public var displayName: String?
    @NSManaged public var followersCount: Int32
    @NSManaged public var followingCount: Int32
    @NSManaged public var header: URL?
    @NSManaged public var id: String
    @NSManaged public var locked: Bool
    @NSManaged public var note: String?
    @NSManaged public var serverUrl: URL
    @NSManaged public var statusesCount: Int32
    @NSManaged public var url: URL?
    @NSManaged public var username: String
    @NSManaged public var statuses: Set<StatusData>?
    @NSManaged public var viewedStatuses: Set<ViewedStatus>?
    @NSManaged public var accountRelationships: Set<AccountRelationship>?
    @NSManaged public var lastSeenStatusId: String?
}

// MARK: Generated accessors for statuses
extension AccountData {

    @objc(addStatusesObject:)
    @NSManaged public func addToStatuses(_ value: StatusData)

    @objc(removeStatusesObject:)
    @NSManaged public func removeFromStatuses(_ value: StatusData)

    @objc(addStatuses:)
    @NSManaged public func addToStatuses(_ values: NSSet)

    @objc(removeStatuses:)
    @NSManaged public func removeFromStatuses(_ values: NSSet)
    
    @objc(addViewedStatusesObject:)
    @NSManaged public func addToViewedStatuses(_ value: ViewedStatus)

    @objc(removeViewedStatusesObject:)
    @NSManaged public func removeFromViewedStatuses(_ value: ViewedStatus)

    @objc(addViewedStatuses:)
    @NSManaged public func addToViewedStatuses(_ values: NSSet)

    @objc(removeViewedStatuses:)
    @NSManaged public func removeFromViewedStatuses(_ values: NSSet)
    
    
    @objc(addAccountRelationshipsObject:)
    @NSManaged public func addToAccountRelationships(_ value: AccountRelationship)

    @objc(removeAccountRelationshipsObject:)
    @NSManaged public func removeFromVAccountRelationships(_ value: AccountRelationship)

    @objc(addAccountRelationships:)
    @NSManaged public func addToAccountRelationships(_ values: NSSet)

    @objc(removeAccountRelationships:)
    @NSManaged public func removeFromAccountRelationships(_ values: NSSet)
}

extension AccountData: Identifiable {
}
