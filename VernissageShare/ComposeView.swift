//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import PhotosUI
import PixelfedKit
import ClientKit
import EnvironmentKit
import WidgetsKit
import ServicesKit

struct ComposeView: View {
    @EnvironmentObject var client: Client

    private let attachments: [NSItemProvider]

    public init(attachments: [NSItemProvider]) {
        self.attachments = attachments
    }

    var body: some View {
        NavigationView {
            BaseComposeView(attachments: self.attachments) {
                NotificationCenter.default.post(name: NotificationsName.shareSheetClose, object: nil)
            } onUpload: { photoAttachment in
                await self.upload(photoAttachment)
            }
            .navigationTitle("compose.navigationBar.title")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func upload(_ photoAttachment: PhotoAttachment) async {
        do {
            // Image shouldn't be uploaded yet.
            guard photoAttachment.uploadedAttachment == nil else {
                return
            }

            // From extension we are sending already resized file.
            guard let data = photoAttachment.photoData,
                  let uiImage = UIImage(data: data) else {
                return
            }

            // Compresing to JPEG with extendedRGB color space.
            guard let data = uiImage.getJpegData() else {
                return
            }

            let fileIndex = String.randomString(length: 8)
            if let mediaAttachment = try await self.client.media?.upload(data: data,
                                                                         fileName: "file-\(fileIndex).jpg",
                                                                         mimeType: "image/jpeg") {
                photoAttachment.uploadedAttachment = mediaAttachment
            }
        } catch {
            photoAttachment.uploadError = error
            ErrorService.shared.handle(error, message: "compose.error.postingPhotoFailed", showToastr: true)
        }
    }
}
