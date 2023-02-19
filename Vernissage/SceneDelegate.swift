//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import PixelfedKit
import OAuthSwift

class SceneDelegate: NSObject, UISceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        if url.host == AppConstants.oauthCallbackPart {
            OAuthSwift.handle(url: url)
        }
    }
}
