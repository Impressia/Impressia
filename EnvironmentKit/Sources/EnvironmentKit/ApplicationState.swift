//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import PixelfedKit
import ClientKit

public class ApplicationState: ObservableObject {
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
    @Published public private(set) var account: AccountModel?

    /// The maximum number of allowed characters per status.
    @Published public private(set) var statusMaxCharacters = defaults.statusMaxCharacters

    /// The maximum number of media attachments that can be added to a status.
    @Published public private(set) var statusMaxMediaAttachments = defaults.statusMaxMediaAttachments

    /// Each URL in a status will be assumed to be exactly this many characters.
    @Published public private(set) var statusCharactersReservedPerUrl = defaults.statusCharactersReservedPerUrl

    /// Last status seen by the user.
    @Published public var lastSeenStatusId: String?

    /// Amount of new statuses which are not displayed yet to the user.
    @Published public var amountOfNewStatuses = 0

    /// Model for newly created comment.
    @Published public var newComment: CommentModel?

    /// Active icon name.
    @Published public var activeIcon = "Default"

    /// Tint color in whole application.
    @Published public var tintColor = TintColor.accentColor2

    /// Application theme.
    @Published public var theme = Theme.system

    /// Avatar shape.
    @Published public var avatarShape = AvatarShape.circle

    /// Status id for showed interaction row.
    @Published public var showInteractionStatusId = ""

    /// Should we fire haptic when user change tabs.
    @Published public var hapticTabSelectionEnabled = true

    /// Should we fire haptic when user refresh list.
    @Published public var hapticRefreshEnabled = true

    /// Should we fire haptic when user tap button.
    @Published public var hapticButtonPressEnabled = true

    /// Should we fire haptic when animation is finished.
    @Published public var hapticAnimationEnabled = true

    /// Should we fire haptic when notification occures.
    @Published public var hapticNotificationEnabled = true

    /// Should sensitive photos without mask.
    @Published public var showSensitive = false

    /// Should photo description for visually impaired be displayed.
    @Published public var showPhotoDescription = false

    /// Status which should be shown from URL.
    @Published public var showStatusId: String?

    /// Updated user profile.
    @Published public var updatedProfile: Account?

    /// Information which menu should be shown (top or bottom).
    @Published public var menuPosition = MenuPosition.top

    /// Should avatars be visible on timelines.
    @Published public var showAvatarsOnTimeline = false

    /// Should favourites be visible on timelines.
    @Published public var showFavouritesOnTimeline = false

    public func changeApplicationState(accountModel: AccountModel, instance: Instance?, lastSeenStatusId: String?) {
        self.account = accountModel
        self.lastSeenStatusId = lastSeenStatusId
        self.amountOfNewStatuses = 0

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
        self.amountOfNewStatuses = 0

        self.statusMaxCharacters = ApplicationState.defaults.statusMaxCharacters
        self.statusMaxMediaAttachments = ApplicationState.defaults.statusMaxMediaAttachments
        self.statusCharactersReservedPerUrl = ApplicationState.defaults.statusCharactersReservedPerUrl
    }
}
