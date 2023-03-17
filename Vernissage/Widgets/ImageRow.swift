//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ImageRow: View {
    private let status: StatusData
    private let attachmentsData: [AttachmentData]
    private let firstAttachment: AttachmentData?
    
    @State private var imageHeight: Double
    @State private var imageWidth: Double
    @State private var selected: String
    
    init(statusData: StatusData) {
        self.status = statusData
        self.attachmentsData = statusData.attachments()
        self.firstAttachment = self.attachmentsData.first
        self.selected = String.empty()
        
        // Calculate size of frame (first from cache, then from real image, then from metadata).
        if let firstAttachment, let size = ImageSizeService.shared.get(for: firstAttachment.url) {
            self.imageWidth = size.width
            self.imageHeight = size.height
        } else if let firstAttachment, firstAttachment.metaImageWidth > 0 && firstAttachment.metaImageHeight > 0 {
            let size = ImageSizeService.shared.calculate(for: firstAttachment.url,
                                                         width: firstAttachment.metaImageWidth,
                                                         height: firstAttachment.metaImageHeight)
            self.imageWidth = size.width
            self.imageHeight = size.height
        } else {
            self.imageHeight = UIScreen.main.bounds.width
            self.imageWidth = UIScreen.main.bounds.width
        }
    }
    
    var body: some View {
        if self.attachmentsData.count == 1, let firstAttachment = self.firstAttachment {
            ImageRowItem(status: self.status, attachmentData: firstAttachment) { (imageWidth, imageHeight) in
                // When we download image and calculate real size we have to change view size.
                if imageWidth != self.imageWidth || imageHeight != self.imageHeight {
                    withAnimation(.linear(duration: 0.4)) {
                        self.imageWidth = imageWidth
                        self.imageHeight = imageHeight
                    }
                }
            }
            .frame(width: self.imageWidth, height: self.imageHeight)
        } else {
            TabView(selection: $selected) {
                ForEach(self.attachmentsData, id: \.id) { attachmentData in
                    ImageRowItem(status: self.status, attachmentData: attachmentData) { (imageWidth, imageHeight) in
                        // When we download image and calculate real size we have to change view size (only when image is now visible).
                        if attachmentData.id == self.selected {
                            if imageWidth != self.imageWidth || imageHeight != self.imageHeight {
                                withAnimation(.linear(duration: 0.4)) {
                                    self.imageWidth = imageWidth
                                    self.imageHeight = imageHeight
                                }
                            }
                        }
                    }
                    .tag(attachmentData.id)
                }
            }
            .onChange(of: selected, perform: { attachmentId in
                if let attachment = attachmentsData.first(where: { item in item.id == attachmentId }) {
                    let doubleImageWidth = Double(attachment.metaImageWidth)
                    let doubleImageHeight = Double(attachment.metaImageHeight)
                    
                    if doubleImageWidth != self.imageWidth || doubleImageHeight != self.imageHeight {
                        withAnimation(.linear(duration: 0.4)) {
                            self.imageWidth = doubleImageWidth
                            self.imageHeight = doubleImageHeight
                        }
                    }
                }
            })
            .frame(width: self.imageWidth, height: self.imageHeight)
            .tabViewStyle(PageTabViewStyle())
        }
    }
}
