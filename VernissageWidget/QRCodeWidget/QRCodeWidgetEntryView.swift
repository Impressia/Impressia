//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI

struct QRCodeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    var entry: QRCodeProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall: QRCodeSmallWidgetView(entry: entry)
        case .systemMedium: QRCodeMediumWidgetView(entry: entry)
        case .systemLarge: QRCodeLargeWidgetView(entry: entry)
        default: Text("Not supported")
        }
    }
}
