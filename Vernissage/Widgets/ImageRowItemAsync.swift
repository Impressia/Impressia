//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import NukeUI
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct ImageRowItemAsync: View {
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath

    private var statusViewModel: StatusModel
    private var attachment: AttachmentModel
    private let showAvatar: Bool

    @State private var showThumbImage = false
    @State private var isFavourited = false

    private let onImageDownloaded: (Double, Double) -> Void

    init(statusViewModel: StatusModel,
         attachment: AttachmentModel,
         withAvatar showAvatar: Bool = true, onImageDownloaded: @escaping (_: Double, _: Double) -> Void) {
        self.showAvatar = showAvatar
        self.statusViewModel = statusViewModel
        self.attachment = attachment
        self.onImageDownloaded = onImageDownloaded
    }

    var body: some View {
        LazyImage(url: attachment.url) { state in
            if let image = state.image {
                if self.statusViewModel.sensitive && !self.applicationState.showSensitive {
                    ZStack {
                        ContentWarning(spoilerText: self.statusViewModel.spoilerText) {
                            self.imageContainerView(image: image)
                                .imageContextMenu(statusModel: self.statusViewModel,
                                                  attachmentModel: self.attachment,
                                                  uiImage: state.imageResponse?.image)
                        } blurred: {
                            ZStack {
                                BlurredImage(blurhash: attachment.blurhash)
                                ImageAvatar(displayName: self.statusViewModel.account.displayNameWithoutEmojis,
                                            avatarUrl: self.statusViewModel.account.avatar) {
                                    self.routerPath.navigate(to: .userProfile(accountId: self.statusViewModel.account.id,
                                                                              accountDisplayName: self.statusViewModel.account.displayNameWithoutEmojis,
                                                                              accountUserName: self.statusViewModel.account.acct))
                                }
                            }
                            .onTapGesture {
                                self.navigateToStatus()
                            }
                        }
                    }
                    .onAppear {
                        if let uiImage = state.imageResponse?.image {
                            self.recalculateSizeOfDownloadedImage(uiImage: uiImage)
                        }
                    }
                } else {
                    self.imageContainerView(image: image)
                        .imageContextMenu(statusModel: self.statusViewModel,
                                          attachmentModel: self.attachment,
                                          uiImage: state.imageResponse?.image)
                        .onAppear {
                            if let uiImage = state.imageResponse?.image {
                                self.recalculateSizeOfDownloadedImage(uiImage: uiImage)
                            }
                        }
                }
            } else if state.error != nil {
                ZStack {
                    Rectangle()
                        .fill(Color.placeholderText)
                        .scaledToFill()

                    VStack(alignment: .center) {
                        Spacer()
                        Text("global.error.errorDuringImageDownload", comment: "Cannot download image")
                            .foregroundColor(.systemBackground)
                        Spacer()
                    }
                }
            } else {
                VStack(alignment: .center) {
                    BlurredImage(blurhash: attachment.blurhash)
                        .onTapGesture {
                            self.navigateToStatus()
                        }
                }
            }
        }
        .priority(.high)
    }

    @ViewBuilder
    private func imageContainerView(image: Image) -> some View {
        ZStack {
            self.imageView(image: image)

            if self.showAvatar {
                ImageAvatar(displayName: self.statusViewModel.account.displayNameWithoutEmojis,
                            avatarUrl: self.statusViewModel.account.avatar) {
                    self.routerPath.navigate(to: .userProfile(accountId: self.statusViewModel.account.id,
                                                              accountDisplayName: self.statusViewModel.account.displayNameWithoutEmojis,
                                                              accountUserName: self.statusViewModel.account.acct))
                }
            }

            ImageAlternativeText(text: self.attachment.description) { text in
                self.routerPath.presentedAlert = .alternativeText(text: text)
            }

            ImageFavourite(isFavourited: $isFavourited)
            FavouriteTouch(showFavouriteAnimation: $showThumbImage)
        }
    }

    @ViewBuilder
    private func imageView(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture(count: 2) {
                Task {
                    // Update favourite in Pixelfed server.
                    try? await self.client.statuses?.favourite(statusId: self.statusViewModel.id)
                }

                // Run adnimation and haptic feedback.
                self.showThumbImage = true
                HapticService.shared.fireHaptic(of: .buttonPress)

                // Mark favourite booleans used to show star in the timeline view.
                self.statusViewModel.favourited = true
                withAnimation(.default.delay(2.0)) {
                    self.isFavourited = true
                }
            }
            .onTapGesture {
                self.navigateToStatus()
            }
            .onAppear {
                self.isFavourited = self.statusViewModel.favourited
            }
    }

    private func navigateToStatus() {
        self.routerPath.navigate(to: .status(
            id: statusViewModel.id,
            blurhash: statusViewModel.mediaAttachments.first?.blurhash,
            highestImageUrl: statusViewModel.mediaAttachments.getHighestImage()?.url,
            metaImageWidth: statusViewModel.getImageWidth(),
            metaImageHeight: statusViewModel.getImageHeight()
        ))
    }

    private func recalculateSizeOfDownloadedImage(uiImage: UIImage) {
        let size = ImageSizeService.shared.calculate(for: attachment.url,
                                                     width: uiImage.size.width,
                                                     height: uiImage.size.height)

        self.onImageDownloaded(size.width, size.height)
    }
}
