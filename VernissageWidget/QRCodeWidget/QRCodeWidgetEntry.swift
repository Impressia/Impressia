//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI

struct QRCodeWidgetEntry: TimelineEntry {
    let date: Date
    let accountId: String
    let avatar: UIImage?
    let displayName: String?
    let profileUrl: URL?
    let avatarUrl: URL?
    let portfolioUrl: URL?
}
