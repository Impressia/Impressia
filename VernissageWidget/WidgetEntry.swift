//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import WidgetKit
import SwiftUI

struct WidgetEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
    let avatar: UIImage?
    let displayName: String?
    let statusId: String?
}
