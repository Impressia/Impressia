//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
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
        } else if url.host == AppConstants.statusCallbackPart {
            let statusId = url.string.replacingOccurrences(of: "\(AppConstants.statusUri)/", with: "")
            if statusId.isEmpty == false {
                ApplicationState.shared.showStatusId = statusId
            }
        }
    }
}
