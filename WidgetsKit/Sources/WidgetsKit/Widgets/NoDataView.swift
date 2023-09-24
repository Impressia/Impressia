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
        VStack {
            Image(systemName: self.imageSystemName)
                .font(.largeTitle)
                .padding(.bottom, 4)
            Text(self.text, comment: "No data message")
                .font(.title3)
        }
        .foregroundColor(.customGrayColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
