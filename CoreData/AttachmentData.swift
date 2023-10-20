//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import PixelfedKit

@Model final public class AttachmentData {
    public var id: String
    @Attribute(.externalStorage) public var data: Data?
    public var blurhash: String?
    public var exifCamera: String?
    public var exifCreatedDate: String?
    public var exifExposure: String?
    public var exifLens: String?
    public var previewUrl: URL?
    public var remoteUrl: URL?
    public var statusId: String
    public var text: String?
    public var type: String
    public var url: URL
    public var metaImageWidth: Int32
    public var metaImageHeight: Int32
    public var order: Int32
    public var statusRelation: StatusData?
    
    init(
        blurhash: String? = nil,
        data: Data? = nil,
        exifCamera: String? = nil,
        exifCreatedDate: String? = nil,
        exifExposure: String? = nil,
        exifLens: String? = nil,
        id: String,
        previewUrl: URL? = nil,
        remoteUrl: URL? = nil,
        statusId: String,
        text: String? = nil,
        type: String = "",
        url: URL,
        metaImageWidth: Int32 = .zero,
        metaImageHeight: Int32 = .zero,
        order: Int32 = .zero,
        statusRelation: StatusData? = nil
    ) {
        self.blurhash = blurhash
        self.data = data
        self.exifCamera = exifCamera
        self.exifCreatedDate = exifCreatedDate
        self.exifExposure = exifExposure
        self.exifLens = exifLens
        self.id = id
        self.previewUrl = previewUrl
        self.remoteUrl = remoteUrl
        self.statusId = statusId
        self.text = text
        self.type = type
        self.url = url
        self.metaImageWidth = metaImageWidth
        self.metaImageHeight = metaImageHeight
        self.order = order
        self.statusRelation = statusRelation
    }
}

extension AttachmentData: Identifiable {
}

extension AttachmentData: Comparable {
    public static func < (lhs: AttachmentData, rhs: AttachmentData) -> Bool {
        lhs.id < rhs.id
    }
}

extension AttachmentData {
    func copyFrom(_ attachment: MediaAttachment) {
        self.id = attachment.id
        self.url = attachment.url
        self.blurhash = attachment.blurhash
        self.previewUrl = attachment.previewUrl
        self.remoteUrl = attachment.remoteUrl
        self.text = attachment.description
        self.type = attachment.type.rawValue

        // We can set image width only when it wasn't previusly recalculated.
        if let width = (attachment.meta as? ImageMetadata)?.original?.width, self.metaImageWidth <= 0 && width > 0 {
            self.metaImageWidth = Int32(width)
        }

        // We can set image height only when it wasn't previusly recalculated.
        if let height = (attachment.meta as? ImageMetadata)?.original?.height, self.metaImageHeight <= 0 && height > 0 {
            self.metaImageHeight = Int32(height)
        }
    }
}

extension [AttachmentData] {
    func getHighestImage() -> AttachmentData? {
        var attachment = self.first
        var imgHeight = 0.0

        for item in self {
            let attachmentheight = Double(item.metaImageHeight)
            if attachmentheight > imgHeight {
                attachment = item
                imgHeight = attachmentheight
            }
        }

        return attachment
    }
}

extension AttachmentData {
    func isFaulty() -> Bool {
        return self.isDeleted // || self.isFault
    }
}
