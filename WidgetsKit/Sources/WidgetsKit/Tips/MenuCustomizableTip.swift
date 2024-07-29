//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Foundation
import TipKit

public struct MenuCustomizableTip: Tip {
    public var options: [TipOption] {
        Tips.MaxDisplayCount(2)
    }

    public var title: Text {
        Text(NSLocalizedString("tip.menuCustomizable.title", bundle: Bundle.module, comment: "Menu customizable tip title."))
    }

    public var message: Text? {
        Text(NSLocalizedString("tip.menuCustomizable.message", bundle: Bundle.module, comment: "Menu customizable tip message."))
    }

    public var image: Image? {
        Image(systemName: "hand.tap")
    }
    
    public init() { }
}
