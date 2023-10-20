//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import EnvironmentKit

@Model final public class ApplicationSettings {
    public var currentAccount: String?
    public var theme: Int32
    public var tintColor: Int32
    public var avatarShape: Int32
    public var activeIcon: String
    public var lastRefreshTokens: Date

    public var hapticTabSelectionEnabled: Bool
    public var hapticRefreshEnabled: Bool
    public var hapticButtonPressEnabled: Bool
    public var hapticAnimationEnabled: Bool
    public var hapticNotificationEnabled: Bool

    public var showSensitive: Bool
    public var showPhotoDescription: Bool
    public var menuPosition: Int32
    public var showAvatarsOnTimeline: Bool
    public var showFavouritesOnTimeline: Bool
    public var showAltIconOnTimeline: Bool
    public var warnAboutMissingAlt: Bool
    public var showGridOnUserProfile: Bool
    public var showReboostedStatuses: Bool
    public var hideStatusesWithoutAlt: Bool

    public var customNavigationMenuItem1: Int32
    public var customNavigationMenuItem2: Int32
    public var customNavigationMenuItem3: Int32
    
    init(
        currentAccount: String? = nil,
        theme: Int32 = Int32(Theme.system.rawValue),
        tintColor: Int32 = Int32(TintColor.accentColor2.rawValue),
        avatarShape: Int32 = Int32(AvatarShape.circle.rawValue),
        activeIcon: String = "Default",
        lastRefreshTokens: Date = Date.distantPast,
        hapticTabSelectionEnabled: Bool = true,
        hapticRefreshEnabled: Bool = true,
        hapticButtonPressEnabled: Bool = true,
        hapticAnimationEnabled: Bool = true,
        hapticNotificationEnabled: Bool = true,
        showSensitive: Bool = false,
        showPhotoDescription: Bool = false,
        menuPosition: Int32 = Int32(MenuPosition.top.rawValue),
        showAvatarsOnTimeline: Bool = false,
        showFavouritesOnTimeline: Bool = false,
        showAltIconOnTimeline: Bool = false,
        warnAboutMissingAlt: Bool = true,
        showGridOnUserProfile: Bool = false,
        showReboostedStatuses: Bool = false,
        hideStatusesWithoutAlt: Bool = false,
        customNavigationMenuItem1: Int32 = 1,
        customNavigationMenuItem2: Int32 = 2,
        customNavigationMenuItem3: Int32 = 5
    ) {
        self.currentAccount = currentAccount
        self.theme = theme
        self.tintColor = tintColor
        self.avatarShape = avatarShape
        self.activeIcon = activeIcon
        self.lastRefreshTokens = lastRefreshTokens
        self.hapticTabSelectionEnabled = hapticTabSelectionEnabled
        self.hapticRefreshEnabled = hapticRefreshEnabled
        self.hapticButtonPressEnabled = hapticButtonPressEnabled
        self.hapticAnimationEnabled = hapticAnimationEnabled
        self.hapticNotificationEnabled = hapticNotificationEnabled
        self.showSensitive = showSensitive
        self.showPhotoDescription = showPhotoDescription
        self.menuPosition = menuPosition
        self.showAvatarsOnTimeline = showAvatarsOnTimeline
        self.showFavouritesOnTimeline = showFavouritesOnTimeline
        self.showAltIconOnTimeline = showAltIconOnTimeline
        self.warnAboutMissingAlt = warnAboutMissingAlt
        self.showGridOnUserProfile = showGridOnUserProfile
        self.showReboostedStatuses = showReboostedStatuses
        self.hideStatusesWithoutAlt = hideStatusesWithoutAlt
        self.customNavigationMenuItem1 = customNavigationMenuItem1
        self.customNavigationMenuItem2 = customNavigationMenuItem2
        self.customNavigationMenuItem3 = customNavigationMenuItem3
    }
}

extension ApplicationSettings: Identifiable {
}
