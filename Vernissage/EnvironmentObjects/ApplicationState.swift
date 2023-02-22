//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import SwiftUI
import PixelfedKit

public class ApplicationState: ObservableObject {
    public static let shared = ApplicationState()
    private init() { }

    /// Class with default variables.
    private class Defaults {
        let statusMaxCharacters = 2000
        let statusMaxMediaAttachments = 10
        let statusCharactersReservedPerUrl = 23
    }
    
    /// Default variables.
    private static let defaults = Defaults()
    
    /// Actual signed in account.
    @Published private(set) var account: AccountModel?

    /// The maximum number of allowed characters per status.
    @Published private(set) var statusMaxCharacters = defaults.statusMaxCharacters
    
    /// The maximum number of media attachments that can be added to a status.
    @Published private(set) var statusMaxMediaAttachments = defaults.statusMaxMediaAttachments
    
    /// Each URL in a status will be assumed to be exactly this many characters.
    @Published private(set) var statusCharactersReservedPerUrl = defaults.statusCharactersReservedPerUrl
    
    /// Last status seen by the user.
    @Published var lastSeenStatusId: String?
    
    /// Amount of new statuses which are not displayed yet to the user.
    @Published var amountOfNewStatuses = 0
    
    /// Model for newly created comment.
    @Published var newComment: CommentModel?
    
    /// Tint color in whole application.
    @Published var tintColor = TintColor.accentColor2
    
    /// Application theme.
    @Published var theme = Theme.system
    
    /// Avatar shape.
    @Published var avatarShape = AvatarShape.circle
    
    /// Status id for showed interaction row.
    @Published var showInteractionStatusId = String.empty()
    
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
}
