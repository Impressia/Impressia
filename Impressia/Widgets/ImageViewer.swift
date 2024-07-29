//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ClientKit
import ServicesKit

struct ImageViewer: View {
    @Environment(\.dismiss) private var dismiss

    private let attachmentModel: AttachmentModel
    private let image: Image
    private let closeDragDistance = UIScreen.main.bounds.height / 1.8
    private let imageHeight: Double
    private let imageWidth: Double
    private let imagePosition: Double?

    // Magnification.
    @State private var currentMagnification = 0.0
    @State private var finalMagnification = 1.0

    // Rotation.
    @State private var rotationAngle = Angle.zero

    // Draging.
    @State private var currentOffset = CGSize.zero
    @State private var accumulatedOffset = CGSize.zero

    init(attachmentModel: AttachmentModel, imagePosition: Double) {
        self.attachmentModel = attachmentModel
        self.imagePosition = imagePosition

        if let data = attachmentModel.data, let uiImage = UIImage(data: data) {
            self.image = Image(uiImage: uiImage)
            self.imageHeight = uiImage.size.height
            self.imageWidth = uiImage.size.width
        } else {
            self.image = Image(systemName: "photo")
            self.imageHeight = 200
            self.imageWidth = 200
        }
    }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .tag(attachmentModel.id)
            .offset(currentOffset)
            .rotationEffect(rotationAngle)
            .scaleEffect(finalMagnification + currentMagnification)
            .gesture(dragGesture)
            .gesture(magnificationGesture)
            .gesture(doubleTapGesture)
            .gesture(tapGesture)
            .onAppear {
                self.currentOffset = self.calculateStartingOffset()
                withAnimation {
                    self.currentOffset = CGSize.zero
                }
            }
    }

    @MainActor
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { amount in
                self.currentMagnification = (amount - 1) * self.finalMagnification
            }
            .onEnded { _ in
                self.revertToPrecalculatedMagnification()
            }
    }

    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                withAnimation {
                    if self.finalMagnification == 1.0 {
                        self.currentOffset = CGSize.zero
                        self.accumulatedOffset = CGSize.zero
                        self.currentMagnification = 0
                        self.finalMagnification = 2.0
                    } else {
                        self.currentOffset = CGSize.zero
                        self.accumulatedOffset = CGSize.zero
                        self.currentMagnification = 0
                        self.finalMagnification = 1.0
                    }
                }
            }
    }

    @MainActor
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { amount in
                // Opacity and rotation is working only when we have small image size.
                if self.finalMagnification == 1.0 {
                    // We can move image whatever we want.
                    self.currentOffset = CGSize(width: amount.translation.width + self.accumulatedOffset.width,
                                                height: amount.translation.height + self.accumulatedOffset.height)

                    // Changing angle.
                    self.rotationAngle = Angle(degrees: Double(self.currentOffset.width / 30))
                } else {
                    // Bigger images we can move only horizontally (we have to include magnifications).
                    let offsetWidth = (amount.predictedEndTranslation.width / self.finalMagnification) + self.accumulatedOffset.width

                    withAnimation(.spring()) {
                        self.currentOffset = CGSize(width: offsetWidth, height: 0)
                    }
                }
            } .onEnded { amount in
                self.accumulatedOffset = CGSize(width: (amount.predictedEndTranslation.width / self.finalMagnification) + self.accumulatedOffset.width,
                                                height: (amount.predictedEndTranslation.height / self.finalMagnification) + self.accumulatedOffset.height)

                // Animations only for small images sizes,
                if self.finalMagnification == 1.0 {
                    // When we still are in range visible image then we have to only revert back image to starting position..
                    if self.accumulatedOffset.height > -closeDragDistance && self.accumulatedOffset.height < closeDragDistance {
                        withAnimation(.linear(duration: 0.1)) {
                            self.currentOffset = self.accumulatedOffset
                        }

                        // Revert back image offset.
                        withAnimation(.linear(duration: 0.3).delay(0.1)) {
                            self.currentOffset = CGSize.zero
                            self.accumulatedOffset = CGSize.zero
                            self.rotationAngle = Angle.zero
                        }
                    } else {
                        // Close the screen.
                        withAnimation(.linear(duration: 0.4)) {
                            // We have to set end translations for sure outside the screen.
                            self.currentOffset = CGSize(width: amount.predictedEndTranslation.width * 2, height: amount.predictedEndTranslation.height * 2)
                            self.rotationAngle = Angle(degrees: Double(amount.predictedEndTranslation.width / 30))
                            self.accumulatedOffset = CGSize.zero
                        }

                        self.asyncAfter(0.35) {
                            withoutAnimation {
                                self.dismiss()
                            }
                        }
                    }
                } else {
                    self.moveToEdge()
                }
            }
    }

    var tapGesture: some Gesture {
        TapGesture().onEnded({ _ in
            withAnimation {
                self.currentMagnification = 0
                self.finalMagnification = 1.0
                self.currentOffset = self.calculateStartingOffset()
            }

            self.asyncAfter(0.35) {
                withoutAnimation {
                    self.dismiss()
                }
            }
        })
    }

    @MainActor
    private func revertToPrecalculatedMagnification() {
        let magnification = self.finalMagnification + self.currentMagnification

        if magnification < 1.0 {
            // When image is small we are returning to starting point.
            withAnimation {
                self.finalMagnification = 1.0
                self.currentMagnification = 0

                // Also we have to move image to orginal position.
                self.currentOffset = CGSize.zero
            }

            HapticService.shared.fireHaptic(of: .animation)
        } else if magnification > 3.0 {
            // When image is magnified to much we are rturning to 1.5 maginification.
            withAnimation {
                self.finalMagnification = 3.0
                self.currentMagnification = 0
            }

            HapticService.shared.fireHaptic(of: .animation)
        } else {
            self.finalMagnification = magnification
            self.currentMagnification = 0

            // Verify if we have to move image to nearest edge.
            self.moveToEdge()
        }
    }

    @MainActor
    private func moveToEdge() {
        let maxEdgeDistance = ((UIScreen.main.bounds.width * self.finalMagnification) - UIScreen.main.bounds.width) / (2 * self.finalMagnification)

        if self.currentOffset.width > maxEdgeDistance {
            withAnimation(.linear(duration: 0.15)) {
                self.currentOffset = CGSize(width: maxEdgeDistance, height: 0)
                self.accumulatedOffset = self.currentOffset
            }

            HapticService.shared.fireHaptic(of: .animation)
        } else if self.currentOffset.width < -maxEdgeDistance {
            withAnimation(.linear(duration: 0.15)) {
                self.currentOffset = CGSize(width: -maxEdgeDistance, height: 0)
                self.accumulatedOffset = self.currentOffset
            }

            HapticService.shared.fireHaptic(of: .animation)
        }
    }

    private func calculateStartingOffset() -> CGSize {
        // Image size on the screen.
        let calculatedSize = ImageSizeService.shared.calculate(width: self.imageWidth,
                                                               height: self.imageHeight,
                                                               andContainerWidth: UIScreen.main.bounds.size.width)
        let imageOnScreenHeight = calculatedSize.height

        // Calculate full space for image.
        let safeAreaInsetsTop = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20.0
        let safeAreaInsetsBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 20.0
        let spaceForNavigationBar = self.spaceForNavigationBar()
        let spaceForImage = UIScreen.main.bounds.height - safeAreaInsetsTop - safeAreaInsetsBottom - spaceForNavigationBar

        // Calculate empty space.
        let emptySpace = spaceForImage - imageOnScreenHeight

        // Shift of image when image is exactly at the top of the screen.
        let imageShiftToTopScreen = -(emptySpace / 2)

        // Shidt of image also when image has been scrolled top/bottom.
        let imageShiftToImagePosition = imageShiftToTopScreen - (self.imagePosition ?? 0.0)

        // Calculate image shift.
        return CGSize(width: 0, height: imageShiftToImagePosition)
    }

    private func spaceForNavigationBar() -> CGFloat {
        if UIScreen.main.bounds.height == 852.0 || UIScreen.main.bounds.height == 932.0 {
            // iPhone 14 Pro, iPhone 14 Pro Max
            return 78.0
        } else {
            // iPhone SE, iPhone 12 Pro, iPhone 12 Pro Max, iPhone 13 Pro, iPhone 13 Pro Max
            return 88.0
        }
    }
}
