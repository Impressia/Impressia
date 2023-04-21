//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

class NavigationMenuItemDetails: ObservableObject, Identifiable {
    @Published var title: LocalizedStringKey
    @Published var image: String

    @Published var viewMode: MainView.ViewMode {
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
