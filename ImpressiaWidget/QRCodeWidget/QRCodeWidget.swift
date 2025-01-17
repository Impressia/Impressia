//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI

struct QRCodeWidget: Widget {
    let kind: String = "VernissageQRCodeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QRCodeProvider()) { entry in
            QRCodeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Impressia")
        .description("widget.title.qrCodeDescription")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
