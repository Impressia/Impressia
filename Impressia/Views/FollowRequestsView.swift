//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import Foundation
import ServicesKit
import EnvironmentKit
import WidgetsKit

@MainActor
struct FollowRequestsView: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(RouterPath.self) var routerPath
    @Environment(Client.self) var client

    @State private var accounts: [Account] = []
    @State private var downloadedPage = 1
    @State private var allItemsLoaded = false
    @State private var state: ViewState = .loading

    var body: some View {
        self.mainBody()
            .navigationTitle("followingRequests.navigationBar.title")
    }

    @ViewBuilder
    private func mainBody() -> some View {
        switch state {
        case .loading:
            LoadingIndicator()
                .task {
                    await self.loadData(page: self.downloadedPage)
                }
        case .loaded:
            if self.accounts.isEmpty {
                NoDataView(imageSystemName: "person.3.sequence", text: "accounts.title.noAccounts")
            } else {
                self.list()
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading

                self.downloadedPage = 1
                self.allItemsLoaded = false
                self.accounts = []
                await self.loadData(page: self.downloadedPage)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func list() -> some View {
        List {
            ForEach(accounts, id: \.id) { account in
                NavigationLink(value: RouteurDestinations.userProfile(
                    accountId: account.id,
                    accountDisplayName: account.displayNameWithoutEmojis,
                    accountUserName: account.acct)
                ) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            UserAvatar(accountAvatar: account.avatar, size: .list)

                            VStack(alignment: .leading) {
                                Text(account.displayName ?? account.username)
                                    .foregroundColor(.mainTextColor)
                                Text("@\(account.acct)")
                                    .foregroundColor(.customGrayColor)
                                    .font(.footnote)
                            }
                            .padding(.leading, 8)
                        }

                        if let note = account.note, !note.asMarkdown.isEmpty {
                            MarkdownFormattedText(note.asMarkdown)
                                .font(.footnote)
                                .environment(\.openURL, OpenURLAction { url in
                                    routerPath.handle(url: url)
                                })
                                .padding(.vertical, 4)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await self.approve(account: account)
                            }
                        } label: {
                            Label("followingRequests.title.approve", systemImage: "checkmark")
                        }

                        Button(role: .destructive) {
                            Task {
                                await self.reject(account: account)
                            }
                        } label: {
                            Label("followingRequests.title.reject", systemImage: "xmark")
                        }
                        .tint(.dangerColor)
                    }
                }
            }

            if allItemsLoaded == false {
                HStack {
                    Spacer()
                    LoadingIndicator()
                        .task {
                            self.downloadedPage = self.downloadedPage + 1
                            await self.loadData(page: self.downloadedPage)
                        }
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }

    private func loadData(page: Int) async {
        do {
            try await self.loadAccounts(page: page)
            
            withAnimation {
                self.state = .loaded
            }
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "accounts.error.loadingAccountsFailed", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "accounts.error.loadingAccountsFailed", showToastr: false)
            }
        }
    }

    private func loadAccounts(page: Int) async throws {
        let accountsFromApi = try await self.loadFromApi(page: page)

        if accountsFromApi.isEmpty {
            self.allItemsLoaded = true
            return
        }

        await self.downloadAvatars(accounts: accountsFromApi)
        self.accounts.append(contentsOf: accountsFromApi)
    }

    private func loadFromApi(page: Int) async throws -> [Account] {
        // TODO: Workaround for not working paging for favourites/reblogged issues: https://github.com/pixelfed/pixelfed/issues/4182.
        if page == 1 {
            let results = try await self.client.followRequests?.followRequests(limit: 100, page: page)
            return results ?? []
        } else {
            return []
        }
    }

    private func approve(account: Account) async {
        do {
            _ = try await self.client.followRequests?.authorizeRequest(id: account.id)
            self.accounts.removeAll { $0.id == account.id }
        } catch {
            ErrorService.shared.handle(error, message: "followingRequests.error.approve", showToastr: true)
        }
    }

    private func reject(account: Account) async {
        do {
            _ = try await self.client.followRequests?.rejectRequest(id: account.id)
            self.accounts.removeAll { $0.id == account.id }
        } catch {
            ErrorService.shared.handle(error, message: "followingRequests.error.reject", showToastr: true)
        }
    }

    private func downloadAvatars(accounts: [Account]) async {
        await withTaskGroup(of: Void.self) { group in
            for account in accounts {
                group.addTask { await CacheImageService.shared.download(url: account.avatar) }
            }
        }
    }
}
