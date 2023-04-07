//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit

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
            self.imageWidth = size.width
            self.imageHeight = size.height

            self.heightWasPrecalculated = true
        } else if let highestImage, imgHeight > 0 && imgWidth > 0 {
            let size = ImageSizeService.shared.calculate(for: highestImage.url, width: imgWidth, height: imgHeight)
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
        TabView(selection: $selected) {
            ForEach(attachments, id: \.id) { attachment in
                ImageCarouselPicture(attachment: attachment) { (attachment, imageData) in
                    withAnimation {
                        self.recalculateImageHeight(attachment: attachment, imageData: imageData)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        attachment.set(data: imageData)
                    }

                }
                .tag(attachment.id)
            }
        }
        .frame(height: self.imageHeight)
        .tabViewStyle(PageTabViewStyle())
        .onChange(of: selected, perform: { index in
            if let attachment = attachments.first(where: { item in item.id == index }) {
                self.selectedAttachment = attachment
                self.exifCamera = attachment.exifCamera
                self.exifExposure = attachment.exifExposure
                self.exifCreatedDate = attachment.exifCreatedDate
                self.exifLens = attachment.exifLens
                self.description = attachment.description
            }
        })
        .onAppear {
            self.selected = self.attachments.first?.id ?? String.empty()
        }
    }

    private func recalculateImageHeight(attachment: AttachmentModel, imageData: Data) {
        guard heightWasPrecalculated == false else {
            return
        }

        var imageHeight = 0.0
        var imageWidth = 0.0

        for item in attachments {
            if let data = item.data, let image = UIImage(data: data) {
                if image.size.height > imageHeight {
                    imageHeight = image.size.height
                    imageWidth = image.size.width
                }
            }
        }

        if let image = UIImage(data: imageData) {
            if image.size.height > imageHeight {
                imageHeight = image.size.height
                imageWidth = image.size.width
            }
        }

        let size = ImageSizeService.shared.calculate(for: attachment.url, width: imageWidth, height: imageHeight)
        self.imageWidth = size.width
        self.imageHeight = size.height
    }
}
