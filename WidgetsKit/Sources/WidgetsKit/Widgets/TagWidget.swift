//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

public struct TagWidget: View {
    private let value: LocalizedStringKey
    private let color: Color
    private let systemImage: String?

    public init(value: LocalizedStringKey, color: Color, systemImage: String? = nil) {
        self.value = value
        self.color = color
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                    .font(.footnote)
            }

            Text(self.value, comment: "value")
                .foregroundColor(.white)
                .font(.footnote)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Capsule().foregroundColor(self.color))
    }
}
