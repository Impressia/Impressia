//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI

struct BlurredImage: View {
    @State var blurhash: String?
    
    var body: some View {
        if let blurhash = blurhash, let uiImage = UIImage(blurHash: blurhash, size: CGSize(width: 32, height: 32)) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Rectangle()
                .fill(Color.placeholderText)
        }
    }
}

struct BlurredImage_Previews: PreviewProvider {
    static var previews: some View {
        BlurredImage()
    }
}
