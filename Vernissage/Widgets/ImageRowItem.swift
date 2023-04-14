//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ClientKit
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct ImageRowItem: View {
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath

    private let status: StatusData
    private let attachmentData: AttachmentData

    @State private var uiImage: UIImage?
    @State private var showThumbImage = false
    @State private var cancelled = true
    @State private var error: Error?
    @State private var opacity = 0.0
    @State private var isFavourited = false

    private let onImageDownloaded: (Double, Double) -> Void

    init(status: StatusData, attachmentData: AttachmentData, onImageDownloaded: @escaping (_: Double, _: Double) -> Void) {
        self.status = status
        self.attachmentData = attachmentData
        self.onImageDownloaded = onImageDownloaded

        if let imageData = attachmentData.data {
            self.uiImage = UIImage(data: imageData)
        }
    }

    var body: some View {
        if let uiImage {
            if self.status.sensitive && !self.applicationState.showSensitive {
                ZStack {
                    ContentWarning(spoilerText: self.status.spoilerText) {
                        self.imageView(uiImage: uiImage)

                        if showThumbImage {
                            FavouriteTouch {
                                self.showThumbImage = false
                            }
                        }
                    } blurred: {
                        BlurredImage(blurhash: attachmentData.blurhash)
                            .imageAvatar(displayName: self.status.accountDisplayName,
                                         avatarUrl: self.status.accountAvatar)
                            .onTapGesture {
                                self.navigateToStatus()
                            }
                    }
                }
                .opacity(self.opacity)
                .onAppear {
                    withAnimation {
                        self.opacity = 1.0
                    }
                }
            } else {
                ZStack {
                    self.imageView(uiImage: uiImage)

                    if showThumbImage {
                        FavouriteTouch {
                            self.showThumbImage = false
                        }
                    }
                }
                .opacity(self.opacity)
                .onAppear {
                    withAnimation {
                        self.opacity = 1.0
                    }
                }
            }
        } else {
            if cancelled {
                BlurredImage(blurhash: attachmentData.blurhash)
                    .task {
                        await self.downloadImage(attachmentData: attachmentData)
                    }
            } else if let error {
                ZStack {
                    BlurredImage(blurhash: attachmentData.blurhash)

                    ErrorView(error: error) {
                        await self.downloadImage(attachmentData: attachmentData)
                    }
                    .padding()
                }
            } else {
                BlurredImage(blurhash: attachmentData.blurhash)
                    .onTapGesture {
                        self.navigateToStatus()
                    }
                    .task {
                        await self.downloadImage(attachmentData: attachmentData)
                    }
            }
        }
    }

    @ViewBuilder
    private func imageView(uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture(count: 2) {
                Task {
                    // Update favourite in Pixelfed server.
                    _ = try? await self.client.statuses?.favourite(statusId: self.status.id)

                    // Update favourite in local cache (core data).
                    if let accountId = self.applicationState.account?.id {
                        StatusDataHandler.shared.setFavourited(accountId: accountId, statusId: self.status.id)
                    }
                }

                // Run adnimation and haptic feedback.
                self.showThumbImage = true
                HapticService.shared.fireHaptic(of: .buttonPress)

                // Mark favourite booleans used to show star in the timeline view.
                self.isFavourited = true
            }
            .onTapGesture {
                self.navigateToStatus()
            }
            .imageAvatar(displayName: self.status.accountDisplayName,
                         avatarUrl: self.status.accountAvatar)
            .imageFavourite(isFavourited: $isFavourited)
            .imageContextMenu(statusData: self.status)
            .onAppear {
                self.isFavourited = self.status.favourited
            }
    }

    private func downloadImage(attachmentData: AttachmentData) async {
        do {
            if let imageData = try await RemoteFileService.shared.fetchData(url: attachmentData.url),
               let downloadedImage = UIImage(data: imageData) {

                let size = ImageSizeService.shared.calculate(for: attachmentData.url,
                                                             width: downloadedImage.size.width,
                                                             height: downloadedImage.size.height)

                self.uiImage = downloadedImage
                self.onImageDownloaded(size.width, size.height)

                HomeTimelineService.shared.update(attachment: attachmentData, withData: imageData, imageWidth: size.width, imageHeight: size.height)
                self.error = nil
                self.cancelled = false
            }
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "global.error.errorDuringImageDownload")
                self.error = error
            } else {
                ErrorService.shared.handle(error, message: "global.error.canceledImageDownload")
                self.cancelled = true
            }
        }
    }

    private func navigateToStatus() {
        self.routerPath.navigate(to: .status(
            id: status.rebloggedStatusId ?? status.id,
            blurhash: status.attachments().first?.blurhash,
            highestImageUrl: status.attachments().getHighestImage()?.url,
            metaImageWidth: status.attachments().first?.metaImageWidth,
            metaImageHeight: status.attachments().first?.metaImageHeight
        ))
    }
}
