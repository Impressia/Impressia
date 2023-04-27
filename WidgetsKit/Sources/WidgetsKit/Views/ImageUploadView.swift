//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ServicesKit

public struct ImageUploadView: View {
    @ObservedObject public var photoAttachment: PhotoAttachment

    private let delete: () -> Void
    private let open: () -> Void
    private let upload: () -> Void

    public init(photoAttachment: PhotoAttachment, open: @escaping () -> Void, delete: @escaping () -> Void, upload: @escaping () -> Void) {
        self.photoAttachment = photoAttachment
        self.delete = delete
        self.open = open
        self.upload = upload
    }

    public var body: some View {
        if photoAttachment.uploadError != nil || photoAttachment.loadError != nil {
            Menu {
                if photoAttachment.uploadError != nil {
                    Button {
                        HapticService.shared.fireHaptic(of: .buttonPress)
                        self.upload()
                    } label: {
                        Label("compose.title.tryToUpload", systemImage: "exclamationmark.arrow.triangle.2.circlepath")
                    }

                    Divider()
                }

                Button(role: .destructive) {
                    HapticService.shared.fireHaptic(of: .buttonPress)
                    self.delete()
                } label: {
                    Label("compose.title.delete", systemImage: "trash")
                        .tint(.red)
                }
            } label: {
                ZStack {
                    self.imageView()
                        .blur(radius: 10)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Image(systemName: "exclamationmark.triangle.fill")
                    }
            }
        } else if photoAttachment.uploadedAttachment == nil {
            ZStack {
                self.imageView()
                    .blur(radius: 10)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    LoadingIndicator(isVisible: Binding.constant(true))
                }
        } else {
            Menu {
                Button {
                    HapticService.shared.fireHaptic(of: .buttonPress)
                    self.open()
                } label: {
                    Label("compose.title.edit", systemImage: "pencil")
                }

                Divider()

                Button(role: .destructive) {
                    HapticService.shared.fireHaptic(of: .buttonPress)
                    self.delete()
                } label: {
                    Label("compose.title.delete", systemImage: "trash")
                }
            } label: {
                self.imageView()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    @ViewBuilder
    private func imageView() -> some View {
        if let photoData = self.photoAttachment.photoData, let uiImage =  UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
        } else {
            Image("Blurhash")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
        }
    }
}
