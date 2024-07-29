//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

class SelectedMenuItemDetails: Identifiable {
    public let position: Int
    public var viewMode: MainView.ViewMode
    
    init(position: Int, viewMode: MainView.ViewMode) {
        self.position = position
        self.viewMode = viewMode
    }
}
