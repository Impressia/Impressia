//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import SwiftUI
import PixelfedKit

struct ImageRowAsync: View {
    private let statusViewModel: StatusModel
    private let firstAttachment: AttachmentModel?

    @State private var selected: String
    @State private var imageHeight: Double
    @State private var imageWidth: Double
    
    init(statusViewModel: StatusModel) {
        self.statusViewModel = statusViewModel
        self.firstAttachment = statusViewModel.mediaAttachments.first
        self.selected = String.empty()
        
        // Calculate size of frame (first from cache, then from metadata).
        if let firstAttachment, let size = ImageSizeService.shared.get(for: firstAttachment.url) {
            self.imageWidth = size.width
            self.imageHeight = size.height
        } else if let firstAttachment,
           let imgHeight = (firstAttachment.meta as? ImageMetadata)?.original?.height,
           let imgWidth = (firstAttachment.meta as? ImageMetadata)?.original?.width {
            
            let size = ImageSizeService.shared.calculate(for: firstAttachment.url, width: imgWidth, height: imgHeight)
            self.imageWidth = size.width
            self.imageHeight = size.height
        } else {
            self.imageWidth = UIScreen.main.bounds.width
            self.imageHeight = UIScreen.main.bounds.width
        }
    }
    
    var body: some View {
        if statusViewModel.mediaAttachments.count == 1, let firstAttachment = self.firstAttachment {
            ImageRowItemAsync(statusViewModel: self.statusViewModel, attachment: firstAttachment) { (imageWidth, imageHeight) in
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
                ForEach(statusViewModel.mediaAttachments, id: \.id) { attachment in
                    ImageRowItemAsync(statusViewModel: self.statusViewModel, attachment: attachment) { (imageWidth, imageHeight) in
                        // When we download image and calculate real size we have to change view size (only when image is now visible).
                        if attachment.id == self.selected {
                            if imageWidth != self.imageWidth || imageHeight != self.imageHeight {
                                withAnimation(.linear(duration: 0.4)) {
                                    self.imageWidth = imageWidth
                                    self.imageHeight = imageHeight
                                }
                            }
                        }
                    }
                    .tag(attachment.id)
                }
            }
            .onChange(of: selected, perform: { attachmentId in
                if let attachment = self.statusViewModel.mediaAttachments.first(where: { item in item.id == attachmentId }) {
                    if let size = ImageSizeService.shared.get(for: attachment.url) {
                        if size.width != self.imageWidth || size.height != self.imageHeight {
                            withAnimation(.linear(duration: 0.4)) {
                                self.imageWidth = size.width
                                self.imageHeight = size.height
                            }
                        }
                    }
                }
            })
            .frame(width: self.imageWidth, height: self.imageHeight)
            .tabViewStyle(PageTabViewStyle())
        }
    }
}
