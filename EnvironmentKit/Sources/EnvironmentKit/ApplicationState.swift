//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import PixelfedKit
import ClientKit

@Observable public class ApplicationState {
    public static let shared = ApplicationState()
    private init() { }

    /// Class with default variables.
    private class Defaults {
        let statusMaxCharacters = 500
        let statusMaxMediaAttachments = 4
        let statusCharactersReservedPerUrl = 23
    }

    /// Default variables.
    private static let defaults = Defaults()

    /// Actual signed in account.
    public private(set) var account: AccountModel?

    /// The maximum number of allowed characters per status.
    public private(set) var statusMaxCharacters = defaults.statusMaxCharacters

    /// The maximum number of media attachments that can be added to a status.
    public private(set) var statusMaxMediaAttachments = defaults.statusMaxMediaAttachments

    /// Each URL in a status will be assumed to be exactly this many characters.
    public private(set) var statusCharactersReservedPerUrl = defaults.statusCharactersReservedPerUrl

    /// Last notification seen by the user.
    public var lastSeenNotificationId: String?
    
    /// Information about new notifications.
    public var newNotificationsHasBeenAdded = false
    
    /// Last status seen by the user.
    public var lastSeenStatusId: String?

    /// Amount of new statuses which are not displayed yet to the user.
    public var amountOfNewStatuses = 0

    /// Id of latest published status by the user.
    public var latestPublishedStatusId: String?

    /// Active icon name.
    public var activeIcon = "Default"

    /// Tint color in whole application.
    public var tintColor = TintColor.accentColor2

    /// Application theme.
    public var theme = Theme.system

    /// Avatar shape.
    public var avatarShape = AvatarShape.circle

    /// Status id for showed interaction row.
    public var showInteractionStatusId = ""

    /// Should we fire haptic when user change tabs.
    public var hapticTabSelectionEnabled = true

    /// Should we fire haptic when user refresh list.
    public var hapticRefreshEnabled = true

    /// Should we fire haptic when user tap button.
    public var hapticButtonPressEnabled = true

    /// Should we fire haptic when animation is finished.
    public var hapticAnimationEnabled = true

    /// Should we fire haptic when notification occures.
    public var hapticNotificationEnabled = true

    /// Should sensitive photos without mask.
    public var showSensitive = false

    /// Should photo description for visually impaired be displayed.
    public var showPhotoDescription = false

    /// Status which should be shown from URL.
    public var showStatusId: String?

    /// Account which should be shown from URL.
    public var showAccountId: String?

    /// Updated user profile.
    public var updatedProfile: Account?

    /// Information which menu should be shown (top or bottom).
    public var menuPosition = MenuPosition.top

    /// Should avatars be visible on timelines.
    public var showAvatarsOnTimeline = false

    /// Should favourites be visible on timelines.
    public var showFavouritesOnTimeline = false

    /// Should ALT icon be visible on timelines.
    public var showAltIconOnTimeline = false

    /// Show warning about missing ALT texts on compose screen.
    public var warnAboutMissingAlt = true

    /// Show grid of photos on user profile.
    public var showGridOnUserProfile = false

    /// Show reboosted statuses on home timeline.
    public var showReboostedStatuses = false

    /// Hide statuses without ALT text.
    public var hideStatusesWithoutAlt = false
    
    public func changeApplicationState(accountModel: AccountModel, instance: Instance?, lastSeenStatusId: String?, lastSeenNotificationId: String?) {
        self.account = accountModel
        self.lastSeenNotificationId = lastSeenNotificationId
        self.lastSeenStatusId = lastSeenStatusId
        self.amountOfNewStatuses = 0
        self.newNotificationsHasBeenAdded = false

        if let statusesConfiguration = instance?.configuration?.statuses {
            self.statusMaxCharacters = statusesConfiguration.maxCharacters
            self.statusMaxMediaAttachments = statusesConfiguration.maxMediaAttachments
            self.statusCharactersReservedPerUrl = statusesConfiguration.charactersReservedPerUrl
        } else {
            self.statusMaxCharacters = ApplicationState.defaults.statusMaxCharacters
            self.statusMaxMediaAttachments = ApplicationState.defaults.statusMaxMediaAttachments
            self.statusCharactersReservedPerUrl = ApplicationState.defaults.statusCharactersReservedPerUrl
        }
    }

    public func clearApplicationState() {
        self.account = nil
        self.lastSeenStatusId = nil
        self.lastSeenNotificationId = nil
        self.amountOfNewStatuses = 0
        self.newNotificationsHasBeenAdded = false

        self.statusMaxCharacters = ApplicationState.defaults.statusMaxCharacters
        self.statusMaxMediaAttachments = ApplicationState.defaults.statusMaxMediaAttachments
        self.statusCharactersReservedPerUrl = ApplicationState.defaults.statusCharactersReservedPerUrl
    }
}
