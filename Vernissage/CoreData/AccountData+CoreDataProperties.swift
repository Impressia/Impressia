//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
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
    @NSManaged public var createdAt: String
    @NSManaged public var displayName: String?
    @NSManaged public var followersCount: Int32
    @NSManaged public var followingCount: Int32
    @NSManaged public var header: URL?
    @NSManaged public var id: String
    @NSManaged public var locked: Bool
    @NSManaged public var note: String?
    @NSManaged public var statusesCount: Int32
    @NSManaged public var url: URL?
    @NSManaged public var username: String
    @NSManaged public var clientId: String
    @NSManaged public var clientSecret: String
    @NSManaged public var clientVapidKey: String
    @NSManaged public var serverUrl: URL

}

extension AccountData : Identifiable {

}
