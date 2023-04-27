//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

class SelectedMenuItemDetails: NavigationMenuItemDetails {
    public let position: Int

    init(position: Int, viewMode: MainView.ViewMode) {
        self.position = position
        super.init(viewMode: viewMode)
    }
}
