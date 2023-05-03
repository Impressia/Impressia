//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Nuke
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
    private let imageFromCache: Bool

    @State private var uiImage: UIImage?
    @State private var showThumbImage = false
    @State private var cancelled = false
    @State private var error: Error?
    @State private var opacity = 1.0
    @State private var isFavourited = false

    private let onImageDownloaded: (Double, Double) -> Void

    init(status: StatusData, attachmentData: AttachmentData, onImageDownloaded: @escaping (_: Double, _: Double) -> Void) {
        self.status = status
        self.attachmentData = attachmentData
        self.onImageDownloaded = onImageDownloaded

        // When we are deleting status, for some reason that view is updating during the deleting process,
        // unfortunatelly the entity state is faulty and we cannot do any operations on that entity.
        if status.isFaulty() || attachmentData.isFaulty() {
            self.uiImage = nil
            self.imageFromCache = false

            return
        }

        if let imageData = attachmentData.data {
            self.uiImage = UIImage(data: imageData)
            self.imageFromCache = true
        } else {
            self.imageFromCache = ImagePipeline.shared.cache.containsCachedImage(for: ImageRequest(url: attachmentData.url))
        }
    }

    var body: some View {
        if let uiImage {
            if self.status.sensitive && !self.applicationState.showSensitive {
                ZStack {
                    ContentWarning(spoilerText: self.status.spoilerText) {
                        self.imageContainerView(uiImage: uiImage)
                            .imageContextMenu(statusData: self.status, attachmentData: self.attachmentData, uiImage: uiImage)
                    } blurred: {
                        ZStack {
                            BlurredImage(blurhash: attachmentData.blurhash)
                            ImageAvatar(displayName: self.status.accountDisplayName, avatarUrl: self.status.accountAvatar) {
                                self.routerPath.navigate(to: .userProfile(accountId: self.status.accountId,
                                                                          accountDisplayName: self.status.accountDisplayName,
                                                                          accountUserName: self.status.accountUsername))
                            }
                        }
                        .onTapGesture {
                            self.navigateToStatus()
                        }
                    }
                }
                .opacity(self.opacity)
                .onAppear {
                    if self.imageFromCache == false {
                        self.opacity = 0.0
                        withAnimation {
                            self.opacity = 1.0
                        }
                    }
                }
            } else {
                self.imageContainerView(uiImage: uiImage)
                    .imageContextMenu(statusData: self.status, attachmentData: self.attachmentData, uiImage: uiImage)
                    .opacity(self.opacity)
                    .onAppear {
                        if self.imageFromCache == false {
                            self.opacity = 0.0
                            withAnimation {
                                self.opacity = 1.0
                            }
                        }
                    }
            }
        } else {
            if cancelled {
                BlurredImage(blurhash: attachmentData.blurhash)
                    .task {
                        if !status.isFaulty() && !attachmentData.isFaulty() {
                            if let imageData = await self.downloadImage(attachmentData: attachmentData),
                               let downloadedImage = UIImage(data: imageData) {
                                self.setVariables(imageData: imageData, downloadedImage: downloadedImage)
                            }
                        }
                    }
            } else if let error {
                ZStack {
                    BlurredImage(blurhash: attachmentData.blurhash)

                    ErrorView(error: error) {
                        if !status.isFaulty() && !attachmentData.isFaulty() {
                            if let imageData = await self.downloadImage(attachmentData: attachmentData),
                               let downloadedImage = UIImage(data: imageData) {
                                self.setVariables(imageData: imageData, downloadedImage: downloadedImage)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                BlurredImage(blurhash: attachmentData.blurhash)
                    .onTapGesture {
                        self.navigateToStatus()
                    }
                    .task {
                        if !status.isFaulty() && !attachmentData.isFaulty() {
                            if let imageData = await self.downloadImage(attachmentData: attachmentData),
                               let downloadedImage = UIImage(data: imageData) {
                                self.setVariables(imageData: imageData, downloadedImage: downloadedImage)
                            }
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private func imageContainerView(uiImage: UIImage) -> some View {
        ZStack {
            self.imageView(uiImage: uiImage)

            ImageAvatar(displayName: self.status.accountDisplayName, avatarUrl: self.status.accountAvatar) {
                self.routerPath.navigate(to: .userProfile(accountId: self.status.accountId,
                                                          accountDisplayName: self.status.accountDisplayName,
                                                          accountUserName: self.status.accountUsername))
            }

            ImageFavourite(isFavourited: $isFavourited)
            ImageAlternativeText(text: self.attachmentData.text) { text in
                self.routerPath.presentedAlert = .alternativeText(text: text)
            }

            FavouriteTouch(showFavouriteAnimation: $showThumbImage)
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
                withAnimation(.default.delay(2.0)) {
                    self.isFavourited = true
                }
            }
            .onTapGesture {
                self.navigateToStatus()
            }
            .onAppear {
                self.isFavourited = self.status.favourited
            }
    }

    private func downloadImage(attachmentData: AttachmentData) async -> Data? {
        do {
            if let imageData = try await RemoteFileService.shared.fetchData(url: attachmentData.url) {
                return imageData
            }

            return nil
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "global.error.errorDuringImageDownload")
                self.error = error
            } else {
                ErrorService.shared.handle(error, message: "global.error.canceledImageDownload")
                self.cancelled = true
            }

            return nil
        }
    }

    private func setVariables(imageData: Data, downloadedImage: UIImage) {
        let size = ImageSizeService.shared.calculate(for: attachmentData.url,
                                                     width: downloadedImage.size.width,
                                                     height: downloadedImage.size.height)

        self.onImageDownloaded(size.width, size.height)
        self.uiImage = downloadedImage

        HomeTimelineService.shared.update(attachment: attachmentData, withData: imageData, imageWidth: size.width, imageHeight: size.height)
        self.error = nil
        self.cancelled = false
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
