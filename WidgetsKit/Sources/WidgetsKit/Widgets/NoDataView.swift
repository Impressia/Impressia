//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

public struct NoDataView: View {
    private let imageSystemName: String
    private let text: LocalizedStringKey

    public init(imageSystemName: String, text: LocalizedStringKey) {
        self.imageSystemName = imageSystemName
        self.text = text
    }

    public var body: some View {
        ContentUnavailableView {
            Label(NSLocalizedString("global.title.noSearchResult", bundle: Bundle.module, comment: "There is nothing here"), systemImage: self.imageSystemName)
        } description: {
            Text(self.text, comment: "No data message")
        }
    }
}
