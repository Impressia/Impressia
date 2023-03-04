//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import NukeUI

struct ImageGrid: View {
    @StateObject var photoUrl: PhotoUrl
    
    var body: some View {
        if let url = photoUrl.url {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .aspectRatio(contentMode: .fit)
                } else if state.isLoading {
                    placeholder()
                } else {
                    placeholder()
                }
            }
            .priority(.high)
        } else {
            self.placeholder()
        }
    }
    
    @ViewBuilder
    private func placeholder() -> some View {
        if let imageBlurhash = photoUrl.blurhash, let uiImage = UIImage(blurHash: imageBlurhash, size: CGSize(width: 32, height: 32)) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Rectangle()
                .fill(Color.placeholderText)
                .redacted(reason: .placeholder)
        }
    }
}
