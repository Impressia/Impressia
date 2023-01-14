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

    @Published var accountData: AccountData?
    @Published var tintColor = TintColor.accentColor2
    @Published var theme = Theme.system
    @Published var showInteractionStatusId = String.empty()
}

extension ApplicationState {
    public static var preview: ApplicationState = {
        let applicationState = ApplicationState()
        
        applicationState.accountData = AccountData()
        
        return applicationState
    }()
}
