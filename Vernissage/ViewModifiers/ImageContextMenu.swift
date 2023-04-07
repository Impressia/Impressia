//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

public extension View {
    func imageContextMenu(client: Client, statusModel: StatusModel) -> some View {
        modifier(ImageContextMenu(client: client, id: statusModel.id, url: statusModel.url))
    }

    func imageContextMenu(client: Client, statusData: StatusData) -> some View {
        modifier(ImageContextMenu(client: client, id: statusData.id, url: statusData.url))
    }
}

private struct ImageContextMenu: ViewModifier {
    private let client: Client
    private let id: String
    private let url: URL?

    init(client: Client, id: String, url: URL?) {
        self.client = client
        self.id = id
        self.url = url
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
                }
        }
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
