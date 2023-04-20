//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PhotosUI
import SwiftUI
import PixelfedKit
import ServicesKit

public class PhotoAttachment: ObservableObject, Identifiable, Equatable, Hashable {
    public let id: String

    /// Information about image from photos picker.
    public let photosPickerItem: PhotosPickerItem?

    /// Information about image from share extension.
    public let nsItemProvider: NSItemProvider?

    /// Variable used for presentation layer.
    @Published public var photoData: Data?

    /// Property which stores orginal image file copied from Photos to tmp folder.
    @Published public var photoUrl: URL?

    /// Property stores information after upload to Pixelfed.
    @Published public var uploadedAttachment: UploadedAttachment?

    /// Error from Pixelfed.
    @Published public var uploadError: Error?

    /// Error from device.
    @Published public var loadError: Error?

    public init(photosPickerItem: PhotosPickerItem? = nil, nsItemProvider: NSItemProvider? = nil) {
        self.id = UUID().uuidString

        self.photosPickerItem = photosPickerItem
        self.nsItemProvider = nsItemProvider
    }

    public static func == (lhs: PhotoAttachment, rhs: PhotoAttachment) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.id)
    }
}

public extension PhotoAttachment {

    @MainActor
    func loadImage() async throws {
        if let pickerItem = self.photosPickerItem,
           let transferable = try await pickerItem.createImageFileTranseferable() {
            self.photoUrl = transferable.url
            self.photoData = await ImageCompressService.shared.compressImageFrom(url: transferable.url)

            return
        }

        if let itemProvider = self.nsItemProvider,
           let identifier = itemProvider.registeredTypeIdentifiers.first,
           let handledItemType = FileTypeSupported(rawValue: identifier),
           let transferredFile = try await handledItemType.loadItemContent(item: itemProvider) {
            self.photoUrl = transferredFile.url
            self.photoData = transferredFile.file

            return
        }
    }
}

public extension [PhotoAttachment] {
    func hasUploadedPhotos() -> Bool {
        return self.contains { photoAttachment in
            photoAttachment.uploadedAttachment != nil
        }
    }

    func getUploadedPhotoIds() -> [String] {
        var ids: [String] = []

        for item in self {
            if let uploadedAttachment = item.uploadedAttachment {
                ids.append(uploadedAttachment.id)
            }
        }

        return ids
    }

    func removeTmpFiles() {
        for file in self {
            if let fileUrl = file.photoUrl {
                do {
                    try FileManager.default.removeItem(at: fileUrl)
                } catch {
                    ErrorService.shared.handle(error, message: "Error during removing transferred image from tmp directory.")
                }
            }
        }
    }
}
