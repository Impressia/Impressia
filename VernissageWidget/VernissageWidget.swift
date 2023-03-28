//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
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
        .description("widget.title.description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
