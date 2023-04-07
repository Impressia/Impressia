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
    public let photosPickerItem: PhotosPickerItem

    @Published public var photoData: Data?
    @Published public var uploadedAttachment: UploadedAttachment?
    @Published public var error: Error?

    public init(photosPickerItem: PhotosPickerItem) {
        self.id = UUID().uuidString
        self.photosPickerItem = photosPickerItem
    }

    public static func == (lhs: PhotoAttachment, rhs: PhotoAttachment) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.id)
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
