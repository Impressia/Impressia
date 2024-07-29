//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import AuthenticationServices

public class AuthorizationSession: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

    /// Presentation anchor used during showing in app browser for sign in user (OAuth).
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        DispatchQueue.main.sync {
            return ASPresentationAnchor()
        }
    }
}
