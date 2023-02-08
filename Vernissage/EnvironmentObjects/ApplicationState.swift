//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import SwiftUI
import MastodonKit

public class ApplicationState: ObservableObject {
    public static let shared = ApplicationState()
    private init() { }

    @Published var account: AccountModel?

    @Published var lastSeenStatusId: String?
    @Published var amountOfNewStatuses = 0
    @Published var tintColor = TintColor.accentColor2
    @Published var theme = Theme.system
    @Published var avatarShape = AvatarShape.circle
    @Published var showInteractionStatusId = String.empty()
}
