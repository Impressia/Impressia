//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI

struct PhotoWidget: Widget {
    let kind: String = "VernissageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PhotoProvider()) { entry in
            PhotoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Vernissage")
        .description("widget.title.photoDescription")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
