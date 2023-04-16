//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import ClientKit
import ServicesKit

public extension View {
    func imageContextMenu(statusModel: StatusModel, attachmentModel: AttachmentModel, uiImage: UIImage?) -> some View {
        modifier(ImageContextMenu(id: statusModel.id, url: statusModel.url, altText: attachmentModel.description, uiImage: uiImage))
    }

    func imageContextMenu(statusData: StatusData, attachmentData: AttachmentData, uiImage: UIImage?) -> some View {
        modifier(ImageContextMenu(id: statusData.id, url: statusData.url, altText: attachmentData.text, uiImage: uiImage))
    }
}

private struct ImageContextMenu: ViewModifier {
    private struct AlertInfo: Identifiable {
        enum AlertType {
            case showAlternativeText
            case photoHasBeenSaved
        }

        let id: AlertType
        let title: Text
        let message: Text
    }

    @EnvironmentObject var client: Client

    @State private var alertInfo: AlertInfo?

    private let id: String
    private let url: URL?
    private let altText: String?
    private let uiImage: UIImage?

    init(id: String, url: URL?, altText: String?, uiImage: UIImage?) {
        self.id = id
        self.url = url
        self.altText = altText
        self.uiImage = uiImage
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
                .contextMenu {
                    Button {
                        Task {
                            await self.reboost()
                        }
                    } label: {
                        Label("status.title.reboost", image: "custom.rocket")
                    }

                    Button {
                        Task {
                            await self.favourite()
                        }
                    } label: {
                        Label("status.title.favourite", systemImage: "star")
                    }

                    Button {
                        Task {
                            await self.bookmark()
                        }
                    } label: {
                        Label("status.title.bookmark", systemImage: "bookmark")
                    }

                    Divider()

                    if let url = self.url {
                        Link(destination: url) {
                            Label("status.title.openInBrowser", systemImage: "safari")
                        }

                        ShareLink(item: url) {
                            Label("status.title.shareStatus", systemImage: "square.and.arrow.up")
                        }
                    }

                    Divider()

                    if let altText, altText.count > 0 {
                        Button {
                            self.alertInfo = AlertInfo(
                                id: .showAlternativeText,
                                title: Text("status.title.mediaDescription", comment: "Media description"),
                                message: Text(altText)
                            )
                        } label: {
                            Label("status.title.showMediaDescription", systemImage: "eye.trianglebadge.exclamationmark")
                        }
                    }

                    if let uiImage {
                        Button {
                            let imageSaver = ImageSaver {
                                self.alertInfo = AlertInfo(
                                    id: .photoHasBeenSaved,
                                    title: Text("global.title.success", comment: "Success"),
                                    message: Text("global.title.photoSaved", comment: "Photo has been saved")
                                )
                            }

                            imageSaver.writeToPhotoAlbum(image: uiImage)
                        } label: {
                            Label("status.title.saveImage", systemImage: "square.and.arrow.down")
                        }
                    }
                }
        }
        .alert(item: $alertInfo, content: { info in
            Alert(title: info.title,
                  message: info.message,
                  dismissButton: .default(Text("global.title.ok", comment: "OK")))
        })
    }

    private func reboost() async {
        do {
            _ = try await self.client.statuses?.boost(statusId: self.id)
            ToastrService.shared.showSuccess(NSLocalizedString("status.title.reboosted", comment: "Reboosted"), imageName: "custom.rocket.fill")
        } catch {
            ErrorService.shared.handle(error, message: "status.error.reboostFailed", showToastr: true)
        }
    }

    private func favourite() async {
        do {
            _ = try await self.client.statuses?.favourite(statusId: self.id)
            ToastrService.shared.showSuccess(NSLocalizedString("status.title.favourited", comment: "Favourited"), imageSystemName: "star.fill")
        } catch {
            ErrorService.shared.handle(error, message: "status.error.favouriteFailed", showToastr: true)
        }
    }

    private func bookmark() async {
        do {
            _ = try await self.client.statuses?.bookmark(statusId: self.id)
            ToastrService.shared.showSuccess(NSLocalizedString("status.title.bookmarked", comment: "Bookmarked"), imageSystemName: "bookmark.fill")
        } catch {
            ErrorService.shared.handle(error, message: "status.error.bookmarkFailed", showToastr: true)
        }
    }
}
