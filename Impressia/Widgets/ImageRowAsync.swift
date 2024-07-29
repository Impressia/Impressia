//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import ServicesKit
import WidgetsKit
import EnvironmentKit

struct ImageRowAsync: View {
    private let statusViewModel: StatusModel
    private let firstAttachment: AttachmentModel?
    private let showAvatar: Bool

    @Binding private var containerWidth: Double
    @Binding private var clipToRectangle: Bool

    @State private var selected: String
    @State private var imageHeight: Double
    @State private var imageWidth: Double

    init(statusViewModel: StatusModel,
         withAvatar showAvatar: Bool = true,
         containerWidth: Binding<Double>,
         clipToRectangle: Binding<Bool> = Binding.constant(false)) {
        self.showAvatar = showAvatar
        self.statusViewModel = statusViewModel
        self.firstAttachment = statusViewModel.mediaAttachments.first
        self.selected = String.empty()

        self._containerWidth = containerWidth
        self._clipToRectangle = clipToRectangle

        // Calculate size of frame (first from cache, then from metadata).
        if let firstAttachment, let size = ImageSizeService.shared.get(for: firstAttachment.url) {
            let calculatedSize = ImageSizeService.shared.calculate(width: size.width, height: size.height, andContainerWidth: containerWidth.wrappedValue)

            self.imageWidth = calculatedSize.width
            self.imageHeight = calculatedSize.height
        } else if let firstAttachment,
           let imgHeight = (firstAttachment.meta as? ImageMetadata)?.original?.height,
           let imgWidth = (firstAttachment.meta as? ImageMetadata)?.original?.width {

            ImageSizeService.shared.save(for: firstAttachment.url, width: imgWidth, height: imgHeight)
            let calculatedSize = ImageSizeService.shared.calculate(for: firstAttachment.url, andContainerWidth: containerWidth.wrappedValue)

            self.imageWidth = calculatedSize.width
            self.imageHeight = calculatedSize.height
        } else {
            self.imageWidth = containerWidth.wrappedValue
            self.imageHeight = containerWidth.wrappedValue
        }
    }

    var body: some View {
        if statusViewModel.mediaAttachments.count == 1, let firstAttachment = self.firstAttachment {
            ImageRowItemAsync(statusViewModel: self.statusViewModel,
                              attachment: firstAttachment,
                              withAvatar: self.showAvatar,
                              containerWidth: $containerWidth,
                              clipToRectangle: $clipToRectangle,
                              showSpoilerText: Binding.constant(self.containerWidth > 300)) { (imageWidth, imageHeight) in

                // When we download image and calculate real size we have to change view size.
                let calculatedSize = ImageSizeService.shared.calculate(width: imageWidth, height: imageHeight, andContainerWidth: self.containerWidth)

                if calculatedSize.width != self.imageWidth || calculatedSize.height != self.imageHeight {
                    withAnimation(.linear(duration: 0.4)) {
                        self.imageWidth = calculatedSize.width
                        self.imageHeight = calculatedSize.height
                    }
                }
            }
            .frame(width: self.clipToRectangle ? self.containerWidth : self.imageWidth,
                   height: self.clipToRectangle ? self.containerWidth : self.imageHeight)
            .onChange(of: self.containerWidth) { oldContainerWidth, newContainerWidth in
                let calculatedSize = ImageSizeService.shared.calculate(width: self.imageWidth,
                                                             height: self.imageHeight,
                                                             andContainerWidth: newContainerWidth)
                self.imageWidth = calculatedSize.width
                self.imageHeight = calculatedSize.height
            }
        } else {
            TabView(selection: $selected) {
                ForEach(statusViewModel.mediaAttachments, id: \.id) { attachment in
                    ImageRowItemAsync(statusViewModel: self.statusViewModel,
                                      attachment: attachment,
                                      withAvatar: self.showAvatar,
                                      containerWidth: $containerWidth,
                                      clipToRectangle: $clipToRectangle,
                                      showSpoilerText: Binding.constant(self.containerWidth > 300)) { (imageWidth, imageHeight) in

                        // When we download image and calculate real size we have to change view size (only when image is now visible).
                        let calculatedSize = ImageSizeService.shared.calculate(width: imageWidth, height: imageHeight, andContainerWidth: self.containerWidth)

                        if attachment.id == self.selected {
                            if calculatedSize.width != self.imageWidth || calculatedSize.height != self.imageHeight {
                                withAnimation(.linear(duration: 0.4)) {
                                    self.imageWidth = calculatedSize.width
                                    self.imageHeight = calculatedSize.height
                                }
                            }
                        }
                    }
                    .tag(attachment.id)
                }
            }
            .onChange(of: self.containerWidth) { oldContainerWidth, newContainerWidth in
                let calculatedSize = ImageSizeService.shared.calculate(width: self.imageWidth,
                                                             height: self.imageHeight,
                                                             andContainerWidth: newContainerWidth)
                self.imageWidth = calculatedSize.width
                self.imageHeight = calculatedSize.height
            }
            .onFirstAppear {
                self.selected = self.statusViewModel.mediaAttachments.first?.id ?? String.empty()
            }
            .onChange(of: selected) { oldAttachmentId, newAttachmentId in
                if let attachment = self.statusViewModel.mediaAttachments.first(where: { item in item.id == newAttachmentId }) {
                    if let size = ImageSizeService.shared.get(for: attachment.url) {
                        let calculatedSize = ImageSizeService.shared.calculate(width: size.width,
                                                                               height: size.height,
                                                                               andContainerWidth: self.containerWidth)

                        if calculatedSize.width != self.imageWidth || calculatedSize.height != self.imageHeight {
                            withAnimation(.linear(duration: 0.4)) {
                                self.imageWidth = calculatedSize.width
                                self.imageHeight = calculatedSize.height
                            }
                        }
                    }
                }
            }
            .frame(width: self.clipToRectangle ? self.containerWidth : self.imageWidth,
                   height: self.clipToRectangle ? self.containerWidth : self.imageHeight)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlay(CustomPageTabViewStyleView(pages: self.statusViewModel.mediaAttachments, currentId: $selected))
        }
    }
}
