//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import WidgetKit
import SwiftUI

struct VernissageWidget: Widget {
    let kind: String = "VernissageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VernissageWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Vernissage")
        .description("Widget with photos from Pixelfed.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
