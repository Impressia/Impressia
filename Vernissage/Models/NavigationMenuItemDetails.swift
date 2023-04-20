//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

class NavigationMenuItemDetails: ObservableObject, Identifiable {
    let id: Int32

    @Published var viewMode: MainView.ViewMode
    @Published var title: String
    @Published var image: String

    init(id: Int32, viewMode: MainView.ViewMode, title: String, image: String) {
        self.id = id
        self.viewMode = viewMode
        self.title = title
        self.image = image
    }
}
