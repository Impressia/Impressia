//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import EnvironmentKit

@Model final public class ApplicationSettings {
    public var currentAccount: String? = nil
    public var theme: Int32 = Int32(Theme.system.rawValue)
    public var tintColor: Int32 = Int32(TintColor.accentColor2.rawValue)
    public var avatarShape: Int32 = Int32(AvatarShape.circle.rawValue)
    public var activeIcon: String = "Default"
    public var lastRefreshTokens: Date = Date.distantPast

    public var hapticTabSelectionEnabled: Bool = true
    public var hapticRefreshEnabled: Bool = true
    public var hapticButtonPressEnabled: Bool = true
    public var hapticAnimationEnabled: Bool = true
    public var hapticNotificationEnabled: Bool = true

    public var showSensitive: Bool = false
    public var showApplicationBadge: Bool = false
    public var showPhotoDescription: Bool = false
    public var menuPosition: Int32 = Int32(MenuPosition.top.rawValue)
    public var showAvatarsOnTimeline: Bool = false
    public var showFavouritesOnTimeline: Bool = false
    public var showAltIconOnTimeline: Bool = false
    public var warnAboutMissingAlt: Bool = true
    public var showGridOnUserProfile: Bool = false
    public var showReboostedStatuses: Bool = false
    public var hideStatusesWithoutAlt: Bool = false

    public var customNavigationMenuItem1: Int32 = 1
    public var customNavigationMenuItem2: Int32 = 2
    public var customNavigationMenuItem3: Int32 = 5
    
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
        showApplicationBadge: Bool = false,
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
        self.showApplicationBadge = showApplicationBadge
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
