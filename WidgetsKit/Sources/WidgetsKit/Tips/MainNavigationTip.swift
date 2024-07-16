//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Foundation
import TipKit

public struct MainNavigationTip: Tip {
    public var options: [TipOption] {
        Tips.MaxDisplayCount(1)
    }
    
    public var title: Text {
        Text(NSLocalizedString("tip.mainNavigation.title", bundle: Bundle.module, comment: "Main navigation tip title."))
    }

    public var message: Text? {
        Text(NSLocalizedString("tip.mainNavigation.message", bundle: Bundle.module, comment: "Main navigation tip message."))
    }

    public var image: Image? {
        Image(systemName: "info.circle")
    }
    
    public init() { }
}
