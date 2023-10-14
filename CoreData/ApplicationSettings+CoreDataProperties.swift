//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
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
    @NSManaged public var avatarShape: Int32
    @NSManaged public var activeIcon: String
    @NSManaged public var lastRefreshTokens: Date

    @NSManaged public var hapticTabSelectionEnabled: Bool
    @NSManaged public var hapticRefreshEnabled: Bool
    @NSManaged public var hapticButtonPressEnabled: Bool
    @NSManaged public var hapticAnimationEnabled: Bool
    @NSManaged public var hapticNotificationEnabled: Bool

    @NSManaged public var showSensitive: Bool
    @NSManaged public var showPhotoDescription: Bool
    @NSManaged public var menuPosition: Int32
    @NSManaged public var showAvatarsOnTimeline: Bool
    @NSManaged public var showFavouritesOnTimeline: Bool
    @NSManaged public var showAltIconOnTimeline: Bool
    @NSManaged public var warnAboutMissingAlt: Bool
    @NSManaged public var showGridOnUserProfile: Bool
    @NSManaged public var showReboostedStatuses: Bool
    @NSManaged public var hideStatusesWithoutAlt: Bool

    @NSManaged public var customNavigationMenuItem1: Int32
    @NSManaged public var customNavigationMenuItem2: Int32
    @NSManaged public var customNavigationMenuItem3: Int32
}

extension ApplicationSettings: Identifiable {
}
