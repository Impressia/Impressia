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
struct AccountsView: View {
    public enum ListType: Hashable {
        case followers(entityId: String)
        case following(entityId: String)
        case reblogged(entityId: String)
        case favourited(entityId: String)
        case blocks
        case mutes
        case search(query: String)

        public var title: String {
            switch self {
            case .followers:
                return NSLocalizedString("accounts.navigationBar.followers", comment: "Followers")
            case .following:
                return NSLocalizedString("accounts.navigationBar.following", comment: "Following")
            case .favourited:
                return NSLocalizedString("accounts.navigationBar.favouritedBy", comment: "Favourited by")
            case .reblogged:
                return NSLocalizedString("accounts.navigationBar.reboostedBy", comment: "Reboosted by")
            case .blocks:
                return NSLocalizedString("accounts.navigationBar.blocked", comment: "Blocked")
            case .mutes:
                return NSLocalizedString("accounts.navigationBar.mutes", comment: "Mutes")
            case .search(let query):
                return query
            }
        }
    }

    @Environment(ApplicationState.self) var applicationState
    @Environment(Client.self) var client

    @State var listType: ListType

    @State private var accounts: [Account] = []
    @State private var downloadedPage = 1
    @State private var allItemsLoaded = false
    @State private var state: ViewState = .loading

    var body: some View {
        self.mainBody()
            .navigationTitle(self.listType.title)
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
                    UsernameRow(accountId: account.id,
                                accountAvatar: account.avatar,
                                accountDisplayName: account.displayNameWithoutEmojis,
                                accountUsername: account.acct)
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
        switch self.listType {
        case .followers(let entityId):
            return try await self.client.accounts?.followers(account: entityId, page: page) ?? []
        case .following(let entityId):
            return try await self.client.accounts?.following(account: entityId, page: page) ?? []
        case .favourited(let entityId):
            // TODO: Workaround for not working paging for favourites/reblogged issues: https://github.com/pixelfed/pixelfed/issues/4182.
            if page == 1 {
                return try await self.client.statuses?.favouritedBy(statusId: entityId, limit: 40, page: page) ?? []
            } else {
                return []
            }
        case .reblogged(let entityId):
            // TODO: Workaround for not working paging for favourites/reblogged issues: https://github.com/pixelfed/pixelfed/issues/4182.
            if page == 1 {
                return try await self.client.statuses?.rebloggedBy(statusId: entityId, limit: 40, page: page) ?? []
            } else {
                return []
            }
        case .blocks:
            // TODO: Workaround for not working paging for favourites/reblogged issues: https://github.com/pixelfed/pixelfed/issues/4182.
            if page == 1 {
                return try await self.client.blocks?.blocks(limit: 40, page: page) ?? []
            } else {
                return []
            }
        case .mutes:
            // TODO: Workaround for not working paging for favourites/reblogged issues: https://github.com/pixelfed/pixelfed/issues/4182.
            if page == 1 {
                return try await self.client.mutes?.mutes(limit: 40, page: page) ?? []
            } else {
                return []
            }
        case .search(let query):
            // TODO: Workaround for not working paging for favourites/reblogged issues: https://github.com/pixelfed/pixelfed/issues/4182.
            if page == 1 {
                let results = try await self.client.search?.search(query: query, resultsType: .accounts, limit: 40, page: page)
                return results?.accounts ?? []
            } else {
                return []
            }
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
