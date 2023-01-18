//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import CoreData

extension AccountData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountData> {
        return NSFetchRequest<AccountData>(entityName: "AccountData")
    }

    @NSManaged public var accessToken: String?
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

}

extension AccountData : Identifiable {

}
