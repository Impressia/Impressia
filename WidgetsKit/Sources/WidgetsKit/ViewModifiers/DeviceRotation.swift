//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

public extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

public struct GalleryProperties {
    public let imageColumns: Int
    public let containerWidth: Double
    public let containerHeight: Double
    public let horizontalSize: UserInterfaceSizeClass
}

struct DeviceImageGallery: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    let action: (GalleryProperties) -> Void
    let imageSpacing = 8

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .onRotate { _ in
                    asyncAfter(0.1) {
                        let galleryProperties = self.getGalleryProperties(geometry: geometry, horizontalSize: self.horizontalSizeClass ?? .compact)
                        self.action(galleryProperties)
                    }
                }
                .onChange(of: self.horizontalSizeClass) { oldHorizontalSize, newHorizontalSize in
                    asyncAfter(0.1) {
                        let galleryProperties = self.getGalleryProperties(geometry: geometry, horizontalSize: newHorizontalSize ?? .compact)
                        self.action(galleryProperties)
                    }
                }
                .onAppear {
                    asyncAfter(0.1) {
                        let galleryProperties = self.getGalleryProperties(geometry: geometry, horizontalSize: self.horizontalSizeClass ?? .compact)
                        self.action(galleryProperties)
                    }
                }
        }
    }

    private func getGalleryProperties(geometry: GeometryProxy, horizontalSize: UserInterfaceSizeClass) -> GalleryProperties {
        if horizontalSize == .compact {
            // View like on iPhone.
            return GalleryProperties(imageColumns: 1,
                                     containerWidth: geometry.size.width,
                                     containerHeight: geometry.size.height,
                                     horizontalSize: horizontalSize)
        } else {
            // View like on iPad.
            let imageColumns = geometry.size.width > geometry.size.height ? 3 : 2
            let marginSpacing = self.imageSpacing * (imageColumns - 1)

            return GalleryProperties(imageColumns: imageColumns,
                                     containerWidth: (geometry.size.width - Double(marginSpacing)) / Double(imageColumns),
                                     containerHeight: (geometry.size.height - Double(marginSpacing)) / Double(imageColumns),
                                     horizontalSize: horizontalSize)
        }
    }
}

public extension View {
    func gallery(perform action: @escaping (GalleryProperties) -> Void) -> some View {
        self.modifier(DeviceImageGallery(action: action))
    }
}
