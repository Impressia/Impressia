//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
//

import Foundation
import CoreData


extension ApplicationSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ApplicationSettings> {
        return NSFetchRequest<ApplicationSettings>(entityName: "ApplicationSettings")
    }

    @NSManaged public var currentAccount: String?

}

extension ApplicationSettings : Identifiable {

}
