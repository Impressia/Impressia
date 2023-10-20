//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import Drops
import ClientKit
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct InteractionRow: View {
    typealias DeleteAction = () -> Void

    @Environment(ApplicationState.self) var applicationState
    @Environment(Client.self) var client
    @Environment(RouterPath.self) var routerPath
    @Environment(\.modelContext) private var modelContext

    @State var statusModel: StatusModel

    @State private var repliesCount = 0
    @State private var reblogged = false
    @State private var reblogsCount = 0
    @State private var favourited = false
    @State private var favouritesCount = 0
    @State private var bookmarked = false

    private let delete: DeleteAction?

    public init(statusModel: StatusModel, delete: DeleteAction? = nil) {
        self.statusModel = statusModel
        self.delete = delete
    }

    var body: some View {
        HStack(alignment: .top) {
            if self.statusModel.commentsDisabled == false {
                ActionButton {
                    self.routerPath.presentedSheet = .replyToStatusEditor(status: statusModel)
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: "message")
                        Text("\(repliesCount)")
                            .font(.caption)
                    }
                }

                Spacer()
            }

            ActionButton {
                await self.reboost()
            } label: {
                HStack(alignment: .center) {
                    Image(self.reblogged ? "custom.rocket.fill" : "custom.rocket")
                    Text("\(self.reblogsCount)")
                        .font(.caption)
                }
            }

            Spacer()

            ActionButton {
                await self.favourite()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: self.favourited ? "star.fill" : "star")
                    Text("\(self.favouritesCount)")
                        .font(.caption)
                }
            }

            Spacer()

            ActionButton {
                await self.bookmark()
            } label: {
                Image(systemName: self.bookmarked ? "bookmark.fill" : "bookmark")
            }

            Spacer()

            Menu {
                NavigationLink(value: RouteurDestinations.accounts(listType: .reblogged(entityId: statusModel.getOrginalStatusId()))) {
                    Label("status.title.reboostedBy", image: "custom.rocket")
                }

                NavigationLink(value: RouteurDestinations.accounts(listType: .favourited(entityId: statusModel.getOrginalStatusId()))) {
                    Label("status.title.favouritedBy", systemImage: "star")
                }

                if let url = statusModel.url {
                    Divider()

                    Link(destination: url) {
                        Label("status.title.openInBrowser", systemImage: "safari")
                    }

                    ShareLink(item: url) {
                        Label("status.title.shareStatus", systemImage: "square.and.arrow.up")
                    }
                }

                if self.statusModel.account.id == self.applicationState.account?.id {
                    Section(header: Text("status.title.yourStatus", comment: "Your post")) {
                        Button(role: .destructive) {
                            self.deleteStatus()
                        } label: {
                            Label("status.title.delete", systemImage: "trash")
                        }
                    }
                } else {
                    Divider()

                    Button {
                        self.routerPath.presentedSheet = .report(objectType: .post, objectId: self.statusModel.getOrginalStatusId())
                    } label: {
                        Label(NSLocalizedString("status.title.report", comment: "Report"), systemImage: "exclamationmark.triangle")
                    }
                }
            } label: {
                Image(systemName: "gear")
            }
        }
        .font(.title3)
        .fontWeight(.bold)
        .onAppear {
            self.refreshCounters()
        }
    }

    private func refreshCounters() {
        self.repliesCount = self.statusModel.repliesCount
        self.reblogged = self.statusModel.reblogged
        self.reblogsCount = self.statusModel.reblogsCount
        self.favourited = self.statusModel.favourited
        self.favouritesCount = self.statusModel.favouritesCount
        self.bookmarked = self.statusModel.bookmarked
    }

    private func reboost() async {
        do {
            let status = self.reblogged
            ? try await self.client.statuses?.unboost(statusId: self.statusModel.getOrginalStatusId())
            : try await self.client.statuses?.boost(statusId: self.statusModel.getOrginalStatusId())

            if let status {
                self.reblogsCount = status.reblogsCount == self.reblogsCount
                    ? status.reblogsCount + 1
                    : status.reblogsCount

                self.reblogged = status.reblogged
            }

            ToastrService.shared.showSuccess(self.reblogged ? "status.title.reboosted" : "status.title.unreboosted", imageName: "custom.rocket.fill")
        } catch {
            ErrorService.shared.handle(error, message: "status.error.reboostFailed", showToastr: true)
        }
    }

    private func favourite() async {
        do {
            let status = self.favourited
            ? try await self.client.statuses?.unfavourite(statusId: self.statusModel.getOrginalStatusId())
            : try await self.client.statuses?.favourite(statusId: self.statusModel.getOrginalStatusId())

            if let status {
                self.favouritesCount = status.favouritesCount == self.favouritesCount
                    ? status.favouritesCount + 1
                    : status.favouritesCount

                self.favourited = status.favourited
            }

            ToastrService.shared.showSuccess(self.favourited ? "status.title.favourited" : "status.title.unfavourited", imageSystemName: "star.fill")
        } catch {
            ErrorService.shared.handle(error, message: "status.error.favouriteFailed", showToastr: true)
        }
    }

    private func bookmark() async {
        do {
            _ = self.bookmarked
            ? try await self.client.statuses?.unbookmark(statusId: self.statusModel.getOrginalStatusId())
            : try await self.client.statuses?.bookmark(statusId: self.statusModel.getOrginalStatusId())

            self.bookmarked.toggle()
            ToastrService.shared.showSuccess(self.bookmarked ? "status.title.bookmarked" : "status.title.unbookmarked", imageSystemName: "bookmark.fill")
        } catch {
            ErrorService.shared.handle(error, message: "status.error.bookmarkFailed", showToastr: true)
        }
    }

    private func deleteStatus() {
        Task {
            do {
                // Remove from server.
                try await self.client.statuses?.delete(statusId: self.statusModel.id)

                ToastrService.shared.showSuccess("status.title.statusDeleted", imageSystemName: "checkmark.circle.fill")
                self.delete?()
            } catch {
                ErrorService.shared.handle(error, message: "status.error.deleteFailed", showToastr: true)
            }
        }
    }
}
