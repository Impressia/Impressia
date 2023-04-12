//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

extension Image {
    func avatar(size: Double) -> some View {
        self
            .resizable()
            .clipShape(Circle())
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    .frame(width: size, height: size)
            )
            .shadow(color: .black, radius: 2)
   }
}
