//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct ImagesCarousel: View {
    @State public var attachments: [AttachmentData]
    @State private var height: Double = 0.0

    var body: some View {
        TabView {
            ForEach(attachments, id: \.self) { attachment in
                if let image = UIImage(data: attachment.data) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
        .frame(height: CGFloat(self.height))
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            self.calculateImageHeight()
        }
    }
    
    private func calculateImageHeight() {
        var imageHeight = 0.0
        var imageWidth = 0.0
        
        for item in attachments {
            if let image = UIImage(data: item.data) {
                if image.size.height > imageHeight {
                    imageHeight = image.size.height
                    imageWidth = image.size.width
                }
            }
        }
        
        let divider = imageWidth / UIScreen.main.bounds.size.width
        self.height = imageHeight / divider
    }
}

struct ImagesCarousel_Previews: PreviewProvider {
    static var previews: some View {
        ImagesCarousel(attachments: [])
    }
}
