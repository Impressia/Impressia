//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ImageRow: View {
    private let status: StatusData
    private let imageHeight: Double
    private let imageWidth: Double
    private let attachmentData: AttachmentData?
    
    @State private var uiImage:UIImage?
    
    init(statusData: StatusData) {
        self.status = statusData
        self.attachmentData = statusData.attachments().first
        
        // Calculate size of frame (first from cache, then from real image, then from metadata).
        if let attachmentData, let size = ImageSizeService.shared.get(for: attachmentData.url) {
            self.imageWidth = size.width
            self.imageHeight = size.height
        } else if let attachmentData, let imageData = attachmentData.data, let uiImage = UIImage(data: imageData) {
            self.uiImage = uiImage
            
            let size = ImageSizeService.shared.calculate(for: attachmentData.url, width: uiImage.size.width, height: uiImage.size.height)
            self.imageWidth = size.width
            self.imageHeight = size.height
        } else if let attachmentData, attachmentData.metaImageWidth > 0 && attachmentData.metaImageHeight > 0 {
            let size = ImageSizeService.shared.calculate(for: attachmentData.url,
                                                         width: attachmentData.metaImageWidth,
                                                         height: attachmentData.metaImageHeight)
            self.imageWidth = size.width
            self.imageHeight = size.height
        } else {
            self.uiImage = nil
            self.imageHeight = UIScreen.main.bounds.width * 0.75
            self.imageWidth = UIScreen.main.bounds.width
        }
    }
    
    var body: some View {
        if let attachmentData {
            if let uiImage {
                ZStack {
                    if self.status.sensitive {
                        ContentWarning(blurhash: attachmentData.blurhash, spoilerText: self.status.spoilerText) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .transition(.opacity)
                        }
                    } else {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    
                    if let count = self.status.attachments().count, count > 1 {
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
                BlurredImage(blurhash: attachmentData.blurhash)
                    .frame(width: self.imageWidth, height: self.imageHeight)
                    .task {
                        do {
                            if let imageData = try await RemoteFileService.shared.fetchData(url: attachmentData.url) {
                                HomeTimelineService.shared.update(attachment: attachmentData, withData: imageData)
                                self.uiImage = UIImage(data: imageData)
                            }
                        } catch {
                            ErrorService.shared.handle(error, message: "Cannot download the image.")
                        }
                    }
            }
        }
    }
}
