//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

public class AttachmentModel: ObservableObject, Identifiable {
    public let id: String
    public let type: MediaAttachment.MediaAttachmentType
    public let url: URL

    public let previewUrl: URL?
    public let remoteUrl: URL?
    public let description: String?
    public let blurhash: String?
    public let meta: Metadata?

    public let metaImageWidth: Int32?
    public let metaImageHeight: Int32?

    @Published public var exifCamera: String?
    @Published public var exifCreatedDate: String?
    @Published public var exifExposure: String?
    @Published public var exifLens: String?
    @Published public var data: Data?

    init(id: String,
         type: MediaAttachment.MediaAttachmentType,
         url: URL,
         previewUrl: URL? = nil,
         remoteUrl: URL? = nil,
         description: String? = nil,
         blurhash: String? = nil,
         meta: Metadata? = nil,
         exifCamera: String? = nil,
         exifCreatedDate: String? = nil,
         exifExposure: String? = nil,
         exifLens: String? = nil,
         metaImageWidth: Int32? = nil,
         metaImageHeight: Int32? = nil,
         data: Data? = nil
    ) {
        self.id = id
        self.type = type
        self.url = url
        self.previewUrl = previewUrl
        self.remoteUrl = remoteUrl
        self.description = description
        self.blurhash = blurhash
        self.meta = meta
        self.exifCamera = exifCamera
        self.exifCreatedDate = exifCreatedDate
        self.exifExposure = exifExposure
        self.exifLens = exifLens
        self.metaImageWidth = metaImageWidth
        self.metaImageHeight = metaImageHeight
        self.data = data
    }

    init(attachment: MediaAttachment) {
        self.id = attachment.id
        self.type = attachment.type
        self.url = attachment.url
        self.previewUrl = attachment.previewUrl
        self.remoteUrl = attachment.remoteUrl
        self.description = attachment.description
        self.blurhash = attachment.blurhash
        self.meta = attachment.meta

        self.data = nil
        self.exifCamera = nil
        self.exifCreatedDate = nil
        self.exifExposure = nil
        self.exifLens = nil

        if let width = (attachment.meta as? ImageMetadata)?.original?.width {
            self.metaImageWidth = Int32(width)
        } else {
            self.metaImageWidth = nil
        }

        if let height = (attachment.meta as? ImageMetadata)?.original?.height {
            self.metaImageHeight = Int32(height)
        } else {
            self.metaImageHeight = nil
        }
    }

    public func set(data: Data) {
        self.data = data

        // Read exif information.
        if let exifProperties = self.data?.getExifData() {
            if let make = exifProperties.getExifValue("Make"), let model = exifProperties.getExifValue("Model") {
                self.exifCamera = "\(make) \(model)"
            }

            // "Lens" or "Lens Model"
            if let lens = exifProperties.getExifValue("Lens") {
                self.exifLens = lens
            }

            if let createData = exifProperties.getExifValue("CreateDate") {
                self.exifCreatedDate = createData
            }

            if let focalLenIn35mmFilm = exifProperties.getExifValue("FocalLenIn35mmFilm"),
               let fNumber = exifProperties.getExifValue("FNumber")?.calculateExifNumber(),
               let exposureTime = exifProperties.getExifValue("ExposureTime"),
               let photographicSensitivity = exifProperties.getExifValue("PhotographicSensitivity") {
                self.exifExposure = "\(focalLenIn35mmFilm)mm, f/\(fNumber), \(exposureTime)s, ISO \(photographicSensitivity)"
            }
        }
    }
}

extension [AttachmentModel] {
    func getHighestImage() -> AttachmentModel? {
        var attachment = self.first
        var imgHeight = 0.0

        for item in self {
            let attachmentheight = Double((item.meta as? ImageMetadata)?.original?.height ?? 0)
            if attachmentheight > imgHeight {
                attachment = item
                imgHeight = attachmentheight
            }
        }

        return attachment
    }
}
