//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ServicesKit
import EnvironmentKit

@MainActor
public struct ImageUploadView: View {
    @Environment(ApplicationState.self) var applicationState
    public var photoAttachment: PhotoAttachment

    private let size: Double
    private let delete: () -> Void
    private let open: () -> Void
    private let upload: () -> Void

    public init(photoAttachment: PhotoAttachment,
                size: Double,
                open: @escaping () -> Void,
                delete: @escaping () -> Void,
                upload: @escaping () -> Void) {
        self.photoAttachment = photoAttachment
        self.size = size
        self.delete = delete
        self.open = open
        self.upload = upload
    }

    public var body: some View {
        if photoAttachment.uploadError != nil || photoAttachment.loadError != nil {
            ZStack {
                self.imageView(showAccessories: true, blur: true)

                if photoAttachment.uploadError != nil {
                    Button {
                        HapticService.shared.fireHaptic(of: .buttonPress)
                        self.upload()
                    } label: {
                        Text("compose.title.tryToUpload", bundle: Bundle.module, comment: "Try to upload")
                            .font(.caption)
                    }.buttonStyle(.borderedProminent)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24))
                }
            }
        } else if photoAttachment.uploadedAttachment == nil {
            ZStack {
                self.imageView(showAccessories: false, blur: true)
                LoadingIndicator()
            }
        } else {
            self.imageView(showAccessories: true, blur: false)
        }
    }

    @ViewBuilder
    private func imageView(showAccessories: Bool, blur: Bool) -> some View {
        if let photoData = self.photoAttachment.photoData, let uiImage = UIImage(data: photoData) {
            self.imageContent(showAccessories: showAccessories, blur: blur) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: self.size - 6, height: self.size - 6)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .if(blur) { $0.blur(radius: 10) }
            }
        } else if let url = photoAttachment.uploadedAttachment?.previewUrl ?? photoAttachment.uploadedAttachment?.url {
            self.imageContent(showAccessories: showAccessories, blur: blur) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: self.size - 6, height: self.size - 6)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .if(blur) { $0.blur(radius: 10) }
                    default:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: self.size - 6, height: self.size - 6)
                    }
                }
            }
        } else {
            Image("Blurhash")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: self.size, height: self.size)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .if(blur) { $0.blur(radius: 10) }
        }
    }

    @ViewBuilder
    private func imageContent<Content: View>(showAccessories: Bool, blur: Bool, @ViewBuilder image: () -> Content) -> some View {
        ZStack(alignment: .bottom) {
            HStack {
                image()
                    .accessibilityLabel(Text("compose.title.edit", bundle: .module))
                    .onTapGesture {
                        HapticService.shared.fireHaptic(of: .buttonPress)
                        self.open()
                    }
                Spacer()
            }

            if showAccessories {
                // Delete button — hidden for existing server attachments.
                if !photoAttachment.isExistingAttachment {
                    VStack {
                        HStack {
                            Spacer()
                            Button(role: .destructive) {
                                HapticService.shared.fireHaptic(of: .buttonPress)
                                self.delete()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color.white, Color.dangerColor)
                                    .opacity(0.8)
                                    .accessibilityLabel(Text("compose.title.delete", bundle: .module))
                            }
                        }
                        Spacer()
                    }
                }

                if self.applicationState.warnAboutMissingAlt {
                    HStack {
                        Spacer()
                        HStack {
                            Group {
                                if (self.photoAttachment.uploadedAttachment?.description ?? "").isEmpty {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(Color.white, Color.dangerColor)
                                        .accessibilityHidden(true)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(Color.white, Color.systemGreen)
                                        .accessibilityHidden(true)
                                }

                                Text("status.title.altText", bundle: Bundle.module, comment: "ALT")
                                    .foregroundStyle(Color.white)
                            }
                            .accessibilityValue(altStatusForPhotoAttachment)
                            .font(.system(size: 12))
                            .shadow(color: .black, radius: 4)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.black.opacity(0.8)))
                        .padding(.bottom, 4)
                        .padding(.trailing, 12)
                        .opacity(0.75)
                    }
                    .if(blur) { $0.blur(radius: 10) }
                }
            }
        }
        .frame(width: self.size, height: self.size)
    }
    
    private var altStatusForPhotoAttachment: Text {
        guard let description = self.photoAttachment.uploadedAttachment?.description else {
            return Text("status.title.altText.a11y.isMissing", bundle: .module)
        }
        return Text(description)
    }
}
