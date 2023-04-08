//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PhotosUI
import SwiftUI
import PixelfedKit

public class PhotoAttachment: ObservableObject, Identifiable, Equatable, Hashable {
    public let id: String

    public let photosPickerItem: PhotosPickerItem?
    public let nsItemProvider: NSItemProvider?

    @Published public var photoData: Data?
    @Published public var uploadedAttachment: UploadedAttachment?
    @Published public var error: Error?

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
    func loadData() async throws -> Data? {
        if let pickerItem = self.photosPickerItem,
           let data = try await pickerItem.loadTransferable(type: Data.self) {
            return data
        }

        if let itemProvider = self.nsItemProvider,
           let data = try await itemProvider.loadData() {
            return data
        }

        return nil
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
}
