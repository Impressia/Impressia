//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData

extension AccountRelationship {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountRelationship> {
        return NSFetchRequest<AccountRelationship>(entityName: "AccountRelationship")
    }

    @NSManaged public var accountId: String
    @NSManaged public var boostedStatusesMuted: Bool
    @NSManaged public var pixelfedAccount: AccountData
}

extension AccountRelationship: Identifiable {
}
