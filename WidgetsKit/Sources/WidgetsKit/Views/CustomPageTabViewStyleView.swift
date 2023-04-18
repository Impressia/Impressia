//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

public struct CustomPageTabViewStyleView<T>: View where T: Identifiable<String> {
    @Binding var currentId: String

    private let pages: [T]
    private let circleSize: CGFloat = 8
    private let circleSpacing: CGFloat = 9

    private let primaryColor = Color.white.opacity(0.7)
    private let secondaryColor = Color.white.opacity(0.4)

    public init(pages: [T], currentId: Binding<String>) {
        self.pages = pages
        self._currentId = currentId
    }

    public var body: some View {
        VStack {
            Spacer()
            HStack(spacing: circleSpacing) {
                ForEach(self.pages, id: \.id) { page in
                    Circle()
                        .fill(currentId == page.id ? primaryColor : secondaryColor)
                        .frame(width: circleSize, height: circleSize)
                        .id(page.id)
                }
            }
        }
        .padding()
    }
}
