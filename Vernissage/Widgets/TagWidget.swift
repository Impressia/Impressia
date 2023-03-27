//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct TagWidget: View {
    private let value: String
    private let color: Color
    private let systemImage: String?
    
    init(value: String, color: Color, systemImage: String? = nil) {
        self.value = value
        self.color = color
        self.systemImage = systemImage
    }
    
    var body: some View {
        HStack {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                    .font(.footnote)
            }
            
            Text(self.value)
                .foregroundColor(.white)
                .font(.footnote)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Capsule().foregroundColor(self.color))
    }
}
