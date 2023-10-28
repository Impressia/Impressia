//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import ServicesKit

struct ImagesCarousel: View {
    @State public var attachments: [AttachmentModel]
    @State private var imageHeight: Double
    @State private var imageWidth: Double
    @State private var selected: String
    @State private var heightWasPrecalculated: Bool

    @Binding public var selectedAttachment: AttachmentModel?
    @Binding public var exifCamera: String?
    @Binding public var exifExposure: String?
    @Binding public var exifCreatedDate: String?
    @Binding public var exifLens: String?
    @Binding public var description: String?

    init(attachments: [AttachmentModel],
         selectedAttachment: Binding<AttachmentModel?>,
         exifCamera: Binding<String?>,
         exifExposure: Binding<String?>,
         exifCreatedDate: Binding<String?>,
         exifLens: Binding<String?>,
         description: Binding<String?>
    ) {
        _selectedAttachment = selectedAttachment
        _exifCamera = exifCamera
        _exifExposure = exifExposure
        _exifCreatedDate = exifCreatedDate
        _exifLens = exifLens
        _description = description

        self.attachments = attachments
        self.selected = String.empty()

        let highestImage = attachments.getHighestImage()
        let imgHeight = Double((highestImage?.meta as? ImageMetadata)?.original?.height ?? 0)
        let imgWidth = Double((highestImage?.meta as? ImageMetadata)?.original?.width ?? 0)

        // Calculate size of frame (first from cache, then from metadata).
        if let highestImage, let size = ImageSizeService.shared.get(for: highestImage.url) {
            let calculatedSize = ImageSizeService.shared.calculate(width: size.width, height: size.height)

            self.imageWidth = calculatedSize.width
            self.imageHeight = calculatedSize.height

            self.heightWasPrecalculated = true
        } else if let highestImage, imgHeight > 0 && imgWidth > 0 {
            ImageSizeService.shared.save(for: highestImage.url, width: imgWidth, height: imgHeight)
            let size = ImageSizeService.shared.calculate(for: highestImage.url)

            self.imageWidth = size.width
            self.imageHeight = size.height

            self.heightWasPrecalculated = true
        } else {
            self.imageWidth = UIScreen.main.bounds.width
            self.imageHeight = UIScreen.main.bounds.width * 0.75
            self.heightWasPrecalculated = false
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            TabView(selection: $selected) {
                ForEach(attachments, id: \.id) { attachment in
                    ImageCarouselPicture(attachment: attachment) { (attachment, imageData) in
                        withAnimation {
                            self.recalculateImageHeight(attachment: attachment, imageData: imageData)
                        }

                        self.asyncAfter(0.4) {
                            attachment.set(data: imageData)
                        }

                    }
                    .tag(attachment.id)
                }
            }
            .padding(0)
            .frame(height: self.imageHeight)
            .tabViewStyle(PageTabViewStyle())
            .onChange(of: selected) { oldIndex, newIndex in
                if let attachment = attachments.first(where: { item in item.id == newIndex }) {
                    self.selectedAttachment = attachment
                    self.exifCamera = attachment.exifCamera
                    self.exifExposure = attachment.exifExposure
                    self.exifCreatedDate = attachment.exifCreatedDate
                    self.exifLens = attachment.exifLens
                    self.description = attachment.description
                }
            }
            Spacer(minLength: 0)
        }
        .padding(0)
        .onAppear {
            self.selected = self.attachments.first?.id ?? String.empty()
        }
    }

    private func recalculateImageHeight(attachment: AttachmentModel, imageData: Data) {
        guard heightWasPrecalculated == false else {
            return
        }

        var maxImageHeight = 0.0
        var maxImageWidth = 0.0

        for item in attachments {
            // Get attachment sizes from cache.
            if let attachmentSize = ImageSizeService.shared.get(for: item.url) {
                if attachmentSize.height > maxImageHeight {
                    maxImageHeight = attachmentSize.height
                    maxImageWidth = attachmentSize.width
                }

                continue
            }

            // When we don't have in cache read from data and add to cache.
            if let data = item.data, let image = UIImage(data: data) {
                ImageSizeService.shared.save(for: item.url, width: image.size.width, height: image.size.height)

                if image.size.height > maxImageHeight {
                    maxImageHeight = image.size.height
                    maxImageWidth = image.size.width
                }
            }
        }

        if let image = UIImage(data: imageData) {
            ImageSizeService.shared.save(for: attachment.url, width: image.size.width, height: image.size.height)

            if image.size.height > maxImageHeight {
                maxImageHeight = image.size.height
                maxImageWidth = image.size.width
            }
        }

        let size = ImageSizeService.shared.calculate(width: maxImageWidth, height: maxImageHeight)
        self.imageWidth = size.width
        self.imageHeight = size.height
    }
}
