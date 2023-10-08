//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData

extension ViewedStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ViewedStatus> {
        return NSFetchRequest<ViewedStatus>(entityName: "ViewedStatus")
    }

    @NSManaged public var id: String
    @NSManaged public var reblogId: String?
    @NSManaged public var date: Date
    @NSManaged public var pixelfedAccount: AccountData
}

extension ViewedStatus: Identifiable {
}
