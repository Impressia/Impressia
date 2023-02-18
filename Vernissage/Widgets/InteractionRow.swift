//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonKit
import Drops

struct InteractionRow: View {
    typealias DeleteAction = () -> Void
    
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath
    
    @State var statusViewModel: StatusModel
    
    @State private var repliesCount = 0
    @State private var reblogged = false
    @State private var reblogsCount = 0
    @State private var favourited = false
    @State private var favouritesCount = 0
    @State private var bookmarked = false
            
    private let delete: DeleteAction?
    
    public init(statusViewModel: StatusModel, delete: DeleteAction? = nil) {
        self.statusViewModel = statusViewModel
        self.delete = delete
    }
    
    var body: some View {
        HStack (alignment: .top) {
            ActionButton {
                self.routerPath.presentedSheet = .replyToStatusEditor(status: statusViewModel)
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "message")
                    Text("\(repliesCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            ActionButton {
                await self.reboost()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: self.reblogged ? "paperplane.fill" : "paperplane")
                    Text("\(self.reblogsCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            ActionButton {
                await self.favourite()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: self.favourited ? "hand.thumbsup.fill" : "hand.thumbsup")
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
                NavigationLink(value: RouteurDestinations.accounts(entityId: statusViewModel.id, listType: .reblogged)) {
                    Label("Reboosted by", systemImage: "paperplane")
                }

                NavigationLink(value: RouteurDestinations.accounts(entityId: statusViewModel.id, listType: .favourited)) {
                    Label("Favourited by", systemImage: "hand.thumbsup")
                }

                if let url = statusViewModel.url {
                    Divider()

                    Link(destination: url) {
                        Label("Open in browser", systemImage: "safari")
                    }

                    ShareLink(item: url) {
                        Label("Share post", systemImage: "square.and.arrow.up")
                    }
                }
                
                if self.statusViewModel.account.id == self.applicationState.account?.id {
                    Section(header: Text("Your post")) {
                        Button(role: .destructive) {
                            self.deleteStatus()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
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
        self.repliesCount = self.statusViewModel.repliesCount
        self.reblogged = self.statusViewModel.reblogged
        self.reblogsCount = self.statusViewModel.reblogsCount
        self.favourited = self.statusViewModel.favourited
        self.favouritesCount = self.statusViewModel.favouritesCount
        self.bookmarked = self.statusViewModel.bookmarked
    }
    
    private func reboost() async {
        do {
            let status = self.reblogged
            ? try await self.client.statuses?.unboost(statusId: self.statusViewModel.id)
            : try await self.client.statuses?.boost(statusId: self.statusViewModel.id)

            if let status {
                self.reblogsCount = status.reblogsCount == self.reblogsCount
                    ? status.reblogsCount + 1
                    : status.reblogsCount

                self.reblogged = status.reblogged
            }

            ToastrService.shared.showSuccess(self.reblogged ? "Reboosted" : "Unreboosted", imageSystemName: "paperplane.fill")
        } catch {
            ErrorService.shared.handle(error, message: "Reboost action failed.", showToastr: true)
        }
    }
    
    private func favourite() async {
        do {
            let status = self.favourited
            ? try await self.client.statuses?.unfavourite(statusId: self.statusViewModel.id)
            : try await self.client.statuses?.favourite(statusId: self.statusViewModel.id)

            if let status {
                self.favouritesCount = status.favouritesCount == self.favouritesCount
                    ? status.favouritesCount + 1
                    : status.favouritesCount

                self.favourited = status.favourited
            }
            
            ToastrService.shared.showSuccess(self.favourited ? "Favourited" : "Unfavourited", imageSystemName: "hand.thumbsup.fill")
        } catch {
            ErrorService.shared.handle(error, message: "Favourite action failed.", showToastr: true)
        }
    }
    
    private func bookmark() async {
        do {
            _ = self.bookmarked
            ? try await self.client.statuses?.unbookmark(statusId: self.statusViewModel.id)
            : try await self.client.statuses?.bookmark(statusId: self.statusViewModel.id)

            self.bookmarked.toggle()
            ToastrService.shared.showSuccess(self.bookmarked ? "Bookmarked" : "Unbookmarked", imageSystemName: "bookmark.fill")
        } catch {
            ErrorService.shared.handle(error, message: "Bookmark action failed.", showToastr: true)
        }
    }
    
    private func deleteStatus() {
        Task {
            do {
                try await self.client.statuses?.delete(statusId: self.statusViewModel.id)
                ToastrService.shared.showSuccess("Post deleted", imageSystemName: "checkmark.circle.fill")
                
                self.delete?()
            } catch {
                ErrorService.shared.handle(error, message: "Delete action failed.", showToastr: true)
            }
        }
    }
}
