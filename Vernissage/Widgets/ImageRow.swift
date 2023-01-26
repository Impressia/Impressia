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
        
        if let imageData = self.attachmentData?.data, let uiImage = UIImage(data: imageData) {
            self.uiImage = uiImage
            
            let imgHeight = uiImage.size.height
            let imgWidth = uiImage.size.width
            let divider = imgWidth / UIScreen.main.bounds.size.width
            let calculatedHeight = imgHeight / divider
            
            self.imageWidth = UIScreen.main.bounds.width
            self.imageHeight = (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : UIScreen.main.bounds.width
        } else if let imgWidth = attachmentData?.metaImageWidth, let imgHeight = attachmentData?.metaImageHeight {
                let divider = Double(imgWidth) / UIScreen.main.bounds.size.width
                let calculatedHeight = Double(imgHeight) / divider
            
                self.uiImage = nil
                self.imageWidth = UIScreen.main.bounds.width
                self.imageHeight = (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : UIScreen.main.bounds.width
        } else {
            self.uiImage = nil
            self.imageHeight = UIScreen.main.bounds.width
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
                                HomeTimelineService.shared.updateAttachmentDataImage(attachmentData: attachmentData, imageData: imageData)
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
