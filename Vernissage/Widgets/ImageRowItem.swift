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

@MainActor
struct ImageRowItem: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(Client.self) var client
    @Environment(RouterPath.self) var routerPath
    @Environment(\.modelContext) private var modelContext

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
                            ImageAvatar(displayName: self.status.accountDisplayName,
                                        avatarUrl: self.status.accountAvatar,
                                        rebloggedAccountDisplayName: self.status.rebloggedAccountDisplayName,
                                        rebloggedAccountAvatar: self.status.rebloggedAccountAvatar) { isAuthor in
                                if isAuthor {
                                    self.routerPath.navigate(to: .userProfile(accountId: self.status.accountId,
                                                                              accountDisplayName: self.status.accountDisplayName,
                                                                              accountUserName: self.status.accountUsername))
                                } else {
                                    if let rebloggedAccountId = self.status.rebloggedAccountId,
                                       let rebloggedAccountUsername = self.status.rebloggedAccountUsername {
                                        self.routerPath.navigate(to: .userProfile(accountId: rebloggedAccountId,
                                                                                  accountDisplayName: self.status.rebloggedAccountDisplayName,
                                                                                  accountUserName: rebloggedAccountUsername))
                                    }
                                }
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

            ImageAvatar(displayName: self.status.accountDisplayName,
                        avatarUrl: self.status.accountAvatar,
                        rebloggedAccountDisplayName: self.status.rebloggedAccountDisplayName,
                        rebloggedAccountAvatar: self.status.rebloggedAccountAvatar) { isAuthor in
                if isAuthor {
                    self.routerPath.navigate(to: .userProfile(accountId: self.status.accountId,
                                                              accountDisplayName: self.status.accountDisplayName,
                                                              accountUserName: self.status.accountUsername))
                } else {
                    if let rebloggedAccountId = self.status.rebloggedAccountId,
                       let rebloggedAccountUsername = self.status.rebloggedAccountUsername {
                        self.routerPath.navigate(to: .userProfile(accountId: rebloggedAccountId,
                                                                  accountDisplayName: self.status.rebloggedAccountDisplayName,
                                                                  accountUserName: rebloggedAccountUsername))
                    }
                }
            }

            ImageFavourite(isFavourited: $isFavourited)
            ImageAlternativeText(text: self.attachmentData.text) { text in
                self.routerPath.presentedAlert = .alternativeText(text: text)
            }

            FavouriteTouch(showFavouriteAnimation: $showThumbImage)
        }
    }
    
    @ViewBuilder
    func reblogInformation() -> some View {
        if let rebloggedAccountAvatar = self.status.rebloggedAccountAvatar,
           let rebloggedAccountDisplayName = self.status.rebloggedAccountDisplayName {
            HStack(alignment: .center, spacing: 4) {
                UserAvatar(accountAvatar: rebloggedAccountAvatar, size: .mini)
                Text(rebloggedAccountDisplayName)
                Image("custom.rocket")
                    .padding(.trailing, 8)
            }
            .font(.footnote)
            .foregroundColor(Color.mainTextColor.opacity(0.4))
            .background(Color.mainTextColor.opacity(0.1))
            .clipShape(Capsule())
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
                        StatusDataHandler.shared.setFavourited(accountId: accountId, statusId: self.status.id, modelContext: modelContext)
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
        ImageSizeService.shared.save(for: attachmentData.url,
                                     width: downloadedImage.size.width,
                                     height: downloadedImage.size.height)

        let size = ImageSizeService.shared.calculate(for: attachmentData.url, andContainerWidth: UIScreen.main.bounds.size.width)
        self.onImageDownloaded(size.width, size.height)

        self.uiImage = downloadedImage
        HomeTimelineService.shared.update(attachment: attachmentData,
                                          withData: imageData,
                                          imageWidth: downloadedImage.size.width,
                                          imageHeight: downloadedImage.size.height,
                                          modelContext: modelContext)
        self.error = nil
        self.cancelled = false
    }

    private func navigateToStatus() {        
        self.routerPath.navigate(to: .status(
            id: status.id,
            blurhash: status.attachments().first?.blurhash,
            highestImageUrl: status.attachments().getHighestImage()?.url,
            metaImageWidth: status.attachments().first?.metaImageWidth,
            metaImageHeight: status.attachments().first?.metaImageHeight
        ))
    }
}
