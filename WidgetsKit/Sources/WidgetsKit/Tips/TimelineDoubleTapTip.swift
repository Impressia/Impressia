//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Foundation
import TipKit

public struct TimelineDoubleTapTip: Tip {
    public var options: [TipOption] {
        Tips.MaxDisplayCount(2)
    }
    
    public var title: Text {
        Text(NSLocalizedString("tip.timelineDoubleTap.title", bundle: Bundle.module, comment: "Timeline double tip title."))
    }

    public var message: Text? {
        Text(NSLocalizedString("tip.timelineDoubleTap.message", bundle: Bundle.module, comment: "Timeline double tip message."))
    }

    public var image: Image? {
        Image(systemName: "star")
    }
    
    public init() { }
}
