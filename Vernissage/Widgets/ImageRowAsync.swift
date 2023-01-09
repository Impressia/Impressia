//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonSwift
import NukeUI

struct ImageRowAsync: View {
    @State public var attachments: [Attachment]
    @State private var imageHeight = UIScreen.main.bounds.width
    @State private var imageWidth = UIScreen.main.bounds.width
    @State private var heightWasPrecalculated = true
    
    var body: some View {
        if let attachment = attachments.first {
            ZStack {
                
                LazyImage(url: attachment.url) { state in
                    if let image = state.image {
                        image
                    } else if state.error != nil {
                        ZStack {
                            Rectangle()
                                .fill(Color.placeholderText)
                                .scaledToFill()
                            
                            VStack(alignment: .center) {
                                Spacer()
                                Text("Cannot download image")
                                    .foregroundColor(.systemBackground)
                                Spacer()
                            }
                        }
                        .frame(width: self.imageWidth, height: self.imageHeight)
                    } else {
                        VStack(alignment: .center) {
                            if let blurhash = attachment.blurhash,
                               let uiImage = UIImage(blurHash: blurhash, size: CGSize(width: 32, height: 32)) {
                                Image(uiImage: uiImage)
                                    .resizable()
                            } else {
                                Rectangle()
                                    .fill(Color.placeholderText)
                            }
                        }
                        .frame(width: self.imageWidth, height: self.imageHeight)
                    }
                }
                .onSuccess { imageResponse in
                    self.recalculateSizeOfDownloadedImage(imageResponse: imageResponse)
                }
                    
                if let count = attachments.count, count > 1 {
                    BottomRight {
                        Text("1 / \(count)")
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .font(.caption2)
                            .foregroundColor(.black)
                            .background(.ultraThinMaterial, in: Capsule())
                    }.padding()
                }
            }
            .frame(width: self.imageWidth, height: self.imageHeight)
            .onAppear {
                self.recalculateSizeFromMetadata()
            }
        } else {
            EmptyView()
        }
    }
    
    private func recalculateSizeOfDownloadedImage(imageResponse: ImageResponse) {
        if heightWasPrecalculated == false {
            let imgHeight = imageResponse.image.size.height
            let imgWidth = imageResponse.image.size.width
            let calculatedHeight = self.calculateHeight(width: imgWidth, height: imgHeight)
            self.imageHeight = (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : UIScreen.main.bounds.width
        }
    }
    
    private func recalculateSizeFromMetadata() {
        if let firstAttachment = attachments.first,
           let imgHeight = (firstAttachment.meta as? ImageMetadata)?.original?.height,
           let imgWidth = (firstAttachment.meta as? ImageMetadata)?.original?.width {
            let calculatedHeight = self.calculateHeight(width: Double(imgWidth), height: Double(imgHeight))
            self.imageHeight = (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : UIScreen.main.bounds.width
        } else {
            heightWasPrecalculated = false
        }
    }
    
    private func calculateHeight(width: Double, height: Double) -> CGFloat {
        let divider = width / UIScreen.main.bounds.size.width
        return height / divider
    }
}

struct ImageRowAsync_Previews: PreviewProvider {
    static var previews: some View {
        ImageRow(attachments: [])
    }
}
