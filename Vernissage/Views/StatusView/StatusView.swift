//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import AVFoundation
import ServicesKit
import WidgetsKit
import EnvironmentKit

struct StatusView: View {
    struct TappedAttachment: Identifiable {
        public let id: String
        public let attachmentModel: AttachmentModel
        public let imagePosition: Double
    }

    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath

    @Environment(\.dismiss) private var dismiss

    @State var statusId: String
    @State var imageBlurhash: String?
    @State var highestImageUrl: URL?
    @State var imageWidth: Int32?
    @State var imageHeight: Int32?

    @State private var state: ViewState = .loading

    @State private var statusViewModel: StatusModel?
    @State private var imagePosition: Double?

    @State private var selectedAttachmentModel: AttachmentModel?
    @State private var tappedAttachment: TappedAttachment?
    @State private var exifCamera: String?
    @State private var exifExposure: String?
    @State private var exifCreatedDate: String?
    @State private var exifLens: String?
    @State private var description: String?

    var body: some View {
        self.mainBody()
            .navigationTitle("status.navigationBar.title")
            .fullScreenCover(item: $tappedAttachment, content: { tappedAttachment in
                ImageViewer(attachmentModel: tappedAttachment.attachmentModel, imagePosition: tappedAttachment.imagePosition)
            })
    }

    @ViewBuilder
    private func mainBody() -> some View {
        switch state {
        case .loading:
            StatusPlaceholderView(imageWidth: self.getImageWidth(), imageHeight: self.getImageHeight(), imageBlurhash: self.imageBlurhash)
                .task {
                    await self.loadData()
                }
        case .loaded:
            if let statusViewModel = self.statusViewModel {
                self.statusView(statusViewModel: statusViewModel)
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                await self.loadData()
            }
            .padding()
        }
    }

    @ViewBuilder
    private func statusView(statusViewModel: StatusModel) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                ImagesCarousel(attachments: statusViewModel.mediaAttachments,
                               selectedAttachment: $selectedAttachmentModel,
                               exifCamera: $exifCamera,
                               exifExposure: $exifExposure,
                               exifCreatedDate: $exifCreatedDate,
                               exifLens: $exifLens,
                               description: $description)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) {
                    self.imagePosition = $0
                }
                .onTapGesture {
                    withoutAnimation {
                        if let attachmentModel = self.selectedAttachmentModel {
                            self.tappedAttachment = TappedAttachment(id: attachmentModel.id,
                                                                     attachmentModel: attachmentModel,
                                                                     imagePosition: self.imagePosition ?? 0.0)
                        }
                    }
                }

                VStack(alignment: .leading) {
                    self.reblogInformation()

                    UsernameRow(accountId: statusViewModel.account.id,
                                accountAvatar: statusViewModel.account.avatar,
                                accountDisplayName: statusViewModel.account.displayNameWithoutEmojis,
                                accountUsername: statusViewModel.account.acct)
                    .onTapGesture {
                        self.routerPath.navigate(to: .userProfile(accountId: statusViewModel.account.id,
                                                                  accountDisplayName: statusViewModel.account.displayNameWithoutEmojis,
                                                                  accountUserName: statusViewModel.account.acct))
                    }

                    MarkdownFormattedText(statusViewModel.content.asMarkdown)
                        .font(.callout)
                        .environment(\.openURL, OpenURLAction { url in
                            routerPath.handle(url: url)
                        })

                    VStack(alignment: .leading) {
                        if let name = statusViewModel.place?.name, let country = statusViewModel.place?.country {
                            LabelIcon(iconName: "mappin.and.ellipse", value: "\(name), \(country)")
                        }

                        LabelIcon(iconName: "camera", value: self.exifCamera)
                        LabelIcon(iconName: "camera.aperture", value: self.exifLens)
                        LabelIcon(iconName: "timelapse", value: self.exifExposure)
                        LabelIcon(iconName: "calendar", value: self.exifCreatedDate?.toDate(.isoDateTimeSec)?.formatted())

                        if self.applicationState.showPhotoDescription {
                            LabelIcon(iconName: "eye.trianglebadge.exclamationmark", value: self.description, isExpandable: true)
                        }
                    }
                    .padding(.bottom, 2)
                    .foregroundColor(.lightGrayColor)

                    HStack {
                        Text("status.title.uploaded", comment: "Uploaded")

                        if let createdAt = statusViewModel.createdAt.toDate(.isoDateTimeMilliSec) {
                            RelativeTime(date: createdAt)
                                .padding(.horizontal, -4)
                        } else {
                            Text(statusViewModel.createdAt.toRelative(.isoDateTimeMilliSec))
                                .padding(.horizontal, -4)
                        }

                        if let applicationName = statusViewModel.application?.name {
                            Text(String(format: NSLocalizedString("status.title.via", comment: "via"), applicationName))
                        }
                    }
                    .foregroundColor(.lightGrayColor)
                    .font(.footnote)

                    InteractionRow(statusModel: statusViewModel) {
                        self.dismiss()
                    }
                    .foregroundColor(.accentColor)
                    .padding(8)
                }
                .padding(8)

                CommentsSectionView(statusId: statusViewModel.id)
            }
        }
        .coordinateSpace(name: "scroll")
    }

    @ViewBuilder
    func reblogInformation() -> some View {
        if let reblogStatus = self.statusViewModel?.reblogStatus {
            HStack(alignment: .center, spacing: 4) {
                UserAvatar(accountAvatar: reblogStatus.account.avatar, size: .mini)
                Text(reblogStatus.account.displayNameWithoutEmojis)
                Image("custom.rocket")
                    .padding(.trailing, 8)
            }
            .font(.footnote)
            .foregroundColor(Color.mainTextColor.opacity(0.4))
            .background(Color.mainTextColor.opacity(0.1))
            .clipShape(Capsule())
        }
    }

    private func loadData() async {
        do {
            // Get status from API.
            if let status = try await self.client.statuses?.status(withId: self.statusId) {
                var statusModel = StatusModel(status: status)

                // We have to always open main status (even if the user is redirected from notifications to comment).
                statusModel = try await self.getMainStatus(status: statusModel)
                if status.id != statusModel.id {
                     self.highestImageUrl = statusModel.mediaAttachments.getHighestImage()?.url
                     self.imageWidth = statusModel.getImageWidth()
                     self.imageHeight = statusModel.getImageHeight()
                }

                self.statusViewModel = statusModel

                // If we have status in database then we can update data.
                // TODO: It seems that Pixelfed didn't support status edit, thus we don't need to update status.
                /*
                if let accountData = self.applicationState.account,
                   let statusDataFromDatabase = StatusDataHandler.shared.getStatusData(accountId: accountData.id, statusId: self.statusId) {
                    _ = try await HomeTimelineService.shared.update(status: statusDataFromDatabase, basedOn: status, for: accountData)
                }
                */
            }

            self.state = .loaded
        } catch NetworkError.notSuccessResponse(let response) {
            if response.statusCode() == HTTPStatusCode.notFound, let accountId = self.applicationState.account?.id {
                StatusDataHandler.shared.remove(accountId: accountId, statusId: self.statusId)
                ErrorService.shared.handle(NetworkError.notSuccessResponse(response), message: "status.error.notFound", showToastr: true)
                self.dismiss()
            }
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "status.error.loadingStatusFailed", showToastr: true)
                self.state = .loaded
            } else {
                ErrorService.shared.handle(error, message: "status.error.loadingStatusFailed", showToastr: false)
            }
        }
    }

    private func setAttachment(_ attachmentData: AttachmentData) {
        exifCamera = attachmentData.exifCamera
        exifExposure = attachmentData.exifExposure
        exifCreatedDate = attachmentData.exifCreatedDate
        exifLens = attachmentData.exifLens
    }

    private func getImageHeight() -> Double {
        if let highestImageUrl = self.highestImageUrl, let imageSize = ImageSizeService.shared.get(for: highestImageUrl) {
            let calculatedSize = ImageSizeService.shared.calculate(width: imageSize.width, height: imageSize.height)
            return calculatedSize.height
        }

        if let imageHeight = self.imageHeight, let imageWidth = self.imageWidth, imageHeight > 0 && imageWidth > 0 {
            let calculatedSize = ImageSizeService.shared.calculate(width: Double(imageWidth), height: Double(imageHeight))
            return calculatedSize.height
        }

        // If we don't have image height and width in metadata, we have to use some constant height.
        return UIScreen.main.bounds.width * 0.75
    }

    private func getImageWidth() -> Double {
        if let highestImageUrl = self.highestImageUrl, let imageSize = ImageSizeService.shared.get(for: highestImageUrl) {
            let calculatedSize = ImageSizeService.shared.calculate(width: imageSize.width, height: imageSize.height)
            return calculatedSize.width
        }

        if let imageHeight = self.imageHeight, let imageWidth = self.imageWidth, imageHeight > 0 && imageWidth > 0 {
            let calculatedSize = ImageSizeService.shared.calculate(width: Double(imageWidth), height: Double(imageHeight))
            return calculatedSize.width
        }

        // If we don't have image height and width in metadata, we have to use some constant height.
        return UIScreen.main.bounds.width * 0.75
    }

    private func getMainStatus(status: StatusModel) async throws -> StatusModel {
        guard let inReplyToId = status.inReplyToId else {
            return status
        }

        guard let previousStatus = try await self.client.statuses?.status(withId: inReplyToId) else {
            throw ClientError.cannotRetrieveStatus
        }

        let previousStatusModel = StatusModel(status: previousStatus)
        return try await self.getMainStatus(status: previousStatusModel)
    }
}
