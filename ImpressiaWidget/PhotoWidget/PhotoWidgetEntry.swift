//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI

struct PhotoWidgetEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
    let avatar: UIImage?
    let displayName: String?
    let statusId: String?
}
