//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import PhotosUI
import SwiftUI
import MastodonKit

public class PhotoAttachment: ObservableObject, Identifiable, Equatable, Hashable {
    public let id: String
    public let photosPickerItem: PhotosPickerItem
    public var photoData: Data

    @Published public var description = String.empty()
    @Published public var alt = String.empty()
    @Published public var sensitive = false
    @Published public var commentingOff = false
    
    @Published public var uploadedAttachment: UploadedAttachment?
    @Published public var error: Error?
    
    init(photosPickerItem: PhotosPickerItem, photoData: Data) {
        self.id = UUID().uuidString
        self.photosPickerItem = photosPickerItem
        self.photoData = photoData
    }
    
    public static func == (lhs: PhotoAttachment, rhs: PhotoAttachment) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.id)
    }
}

extension [PhotoAttachment] {
    public func hasUploadedPhotos() -> Bool {
        return self.contains { photoAttachment in
            photoAttachment.uploadedAttachment != nil
        }
    }
    
    public func getUploadedPhotoIds() -> [String] {
        var ids: [String] = []
        
        for item in self {
            if let uploadedAttachment = item.uploadedAttachment {
                ids.append(uploadedAttachment.id)
            }
        }
        
        return ids
    }
}
