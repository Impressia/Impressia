//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

@Observable class NavigationMenuItemDetails: Identifiable {
    var title: LocalizedStringKey
    var image: String

    var viewMode: MainView.ViewMode {
        didSet {
            self.title = viewMode.title
            self.image = viewMode.image
        }
    }

    init(viewMode: MainView.ViewMode) {
        self.viewMode = viewMode
        self.title = viewMode.title
        self.image = viewMode.image
    }
}
