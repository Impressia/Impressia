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

    @NSManaged public var id: String?
    @NSManaged public var username: String?
    @NSManaged public var acct: String?
    @NSManaged public var displayName: String?
    @NSManaged public var note: String?
    @NSManaged public var url: URL?
    @NSManaged public var avatar: URL?
    @NSManaged public var header: URL?
    @NSManaged public var locked: Bool
    @NSManaged public var createdAt: String?
    @NSManaged public var followersCount: Int32
    @NSManaged public var followingCount: Int32
    @NSManaged public var statusesCount: Int32
    @NSManaged public var accessToken: String?
    @NSManaged public var avatarData: Data?

}

extension AccountData : Identifiable {

}
