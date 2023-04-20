//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PhotosUI
import PixelfedKit
import ClientKit
import UIKit
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct ComposeView: View {
    @EnvironmentObject var routerPath: RouterPath
    @EnvironmentObject var client: Client

    @Environment(\.dismiss) private var dismiss

    private let statusViewModel: StatusModel?

    public init(statusViewModel: StatusModel? = nil) {
        self.statusViewModel = statusViewModel
    }

    var body: some View {
        NavigationView {
            BaseComposeView(statusViewModel: self.statusViewModel) {
                dismiss()
            } onUpload: { photoAttachment in
                await self.upload(photoAttachment)
            }
            .navigationTitle("compose.navigationBar.title")
            .navigationBarTitleDisplayMode(.inline)
        }
        .withOverlayDestinations(overlayDestinations: $routerPath.presentedOverlay)
    }

    private func upload(_ photoAttachment: PhotoAttachment) async {
        do {
            // Image shouldn't be uploaded yet.
            guard photoAttachment.uploadedAttachment == nil else {
                return
            }

            // We are sending orginal file (not file compressed from memory).
            guard let photoUrl = photoAttachment.photoUrl,
                  let data = try? Data(contentsOf: photoUrl),
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
