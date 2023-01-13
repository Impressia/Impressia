//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import CoreData

extension ApplicationSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ApplicationSettings> {
        return NSFetchRequest<ApplicationSettings>(entityName: "ApplicationSettings")
    }

    @NSManaged public var currentAccount: String?
    @NSManaged public var theme: Int32
    @NSManaged public var tintColor: Int32

}

extension ApplicationSettings : Identifiable {

}
