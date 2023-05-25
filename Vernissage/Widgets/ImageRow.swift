//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ServicesKit
import WidgetsKit

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
            let calculatedSize = ImageSizeService.shared.calculate(width: size.width, height: size.height, andContainerWidth: UIScreen.main.bounds.size.width)
            self.imageWidth = calculatedSize.width
            self.imageHeight = calculatedSize.height
        } else if let firstAttachment, firstAttachment.metaImageWidth > 0 && firstAttachment.metaImageHeight > 0 {
            ImageSizeService.shared.save(for: firstAttachment.url,
                                         width: firstAttachment.metaImageWidth,
                                         height: firstAttachment.metaImageHeight)

            let size = ImageSizeService.shared.calculate(for: firstAttachment.url, andContainerWidth: UIScreen.main.bounds.size.width)
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
            .onFirstAppear {
                self.selected = self.attachmentsData.first?.id ?? String.empty()
            }
            .onChange(of: selected, perform: { attachmentId in
                if let attachment = attachmentsData.first(where: { item in item.id == attachmentId }) {
                    let size = ImageSizeService.shared.calculate(width: Double(attachment.metaImageWidth),
                                                                 height: Double(attachment.metaImageHeight),
                                                                 andContainerWidth: UIScreen.main.bounds.size.width)

                    if size.width != self.imageWidth || size.height != self.imageHeight {
                        withAnimation(.linear(duration: 0.4)) {
                            self.imageWidth = size.width
                            self.imageHeight = size.height
                        }
                    }
                }
            })
            .frame(width: self.imageWidth, height: self.imageHeight)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlay(CustomPageTabViewStyleView(pages: self.attachmentsData, currentId: $selected))
        }
    }
}
