//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit
import NukeUI

struct ImageRowAsync: View {
    @State public var statusViewModel: StatusViewModel

    @State private var imageHeight: Double
    @State private var imageWidth: Double
    @State private var heightWasPrecalculated: Bool
    
    init(statusViewModel: StatusViewModel) {
        self.statusViewModel = statusViewModel
        
        if let firstAttachment = statusViewModel.mediaAttachments.first,
           let imgHeight = (firstAttachment.meta as? ImageMetadata)?.original?.height,
           let imgWidth = (firstAttachment.meta as? ImageMetadata)?.original?.width {
            
            let divider = Double(imgWidth) / UIScreen.main.bounds.size.width
            let calculatedHeight = Double(imgHeight) / divider
            
            self.imageWidth = UIScreen.main.bounds.width
            self.imageHeight = (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : UIScreen.main.bounds.width
            self.heightWasPrecalculated = true
        } else {
            self.imageWidth = UIScreen.main.bounds.width
            self.imageHeight = UIScreen.main.bounds.width
            heightWasPrecalculated = false
        }
    }
    
    var body: some View {
        if let attachment = statusViewModel.mediaAttachments.first {
            ZStack {
                LazyImage(url: attachment.url) { state in
                    if let image = state.image {
                        if self.statusViewModel.sensitive {
                            ContentWarning(blurhash: attachment.blurhash, spoilerText: self.statusViewModel.spoilerText) {
                                image
                            }
                        } else {
                            image
                        }
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
                            BlurredImage(blurhash: attachment.blurhash)
                        }
                        .frame(width: self.imageWidth, height: self.imageHeight)
                    }
                }
                .onSuccess { imageResponse in
                    self.recalculateSizeOfDownloadedImage(imageResponse: imageResponse)
                }
                    
                if let count = self.statusViewModel.mediaAttachments.count, count > 1 {
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
        
    private func calculateHeight(width: Double, height: Double) -> CGFloat {
        let divider = width / UIScreen.main.bounds.size.width
        return height / divider
    }
}
