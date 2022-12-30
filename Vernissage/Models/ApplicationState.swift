//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation

public class ApplicationState: ObservableObject {
    public static let shared = ApplicationState()

    @Published var accountData: AccountData?
}

extension ApplicationState {
    public static var preview: ApplicationState = {
        let applicationState = ApplicationState()
        
        applicationState.accountData = AccountData()
        
        return applicationState
    }()
}
