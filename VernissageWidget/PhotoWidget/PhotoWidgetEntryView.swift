//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI

struct PhotoWidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    var entry: PhotoProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall: PhotoSmallWidgetView(entry: entry)
        case .systemMedium: PhotoMediumWidgetView(entry: entry)
        case .systemLarge: PhotoLargeWidgetView(entry: entry)
        default: Text("Not supported")
        }
    }
}
