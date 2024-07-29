//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI

@main
struct ImpressiaWidgetBundle: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        PhotoWidget()
        QRCodeWidget()
    }
}
