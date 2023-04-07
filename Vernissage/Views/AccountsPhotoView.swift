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

struct AccountsPhotoView: View {
    public enum ListType: Hashable {
        case trending
        case search(query: String)
    }

    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath

    @State public var listType: ListType

    @State private var accounts: [Account] = []
    @State private var state: ViewState = .loading

    var body: some View {
        self.mainBody()
            .navigationTitle("trendingAccounts.navigationBar.title")
    }

    @ViewBuilder
    private func mainBody() -> some View {
        switch state {
        case .loading:
            LoadingIndicator()
                .task {
                    await self.loadData()
                }
        case .loaded:
            if self.accounts.isEmpty {
                NoDataView(imageSystemName: "person.3.sequence", text: "trendingAccounts.title.noAccounts")
            } else {
                self.list()
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading

                self.accounts = []
                await self.loadData()
            }
            .padding()
        }
    }

    @ViewBuilder
    private func list() -> some View {
        List {
            ForEach(self.accounts, id: \.id) { account in
                Section {
                    ImagesGrid(gridType: .account(accountId: account.id,
                                                  accountDisplayName: account.displayNameWithoutEmojis,
                                                  accountUserName: account.acct))
                } header: {
                    HStack {
                        UsernameRow(
                            accountId: account.id,
                            accountAvatar: account.avatar,
                            accountDisplayName: account.displayNameWithoutEmojis,
                            accountUsername: account.acct)
                        Spacer()
                    }
                    .textCase(.none)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 12)
                    .onTapGesture {
                        self.routerPath.navigate(to: .userProfile(accountId: account.id,
                                                                  accountDisplayName: account.displayNameWithoutEmojis,
                                                                  accountUserName: account.acct))
                    }
                }
            }
        }
    }

    private func loadData() async {
        do {
            self.accounts = try await self.loadAccounts()
            self.state = .loaded
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "trendingAccounts.error.loadingAccountsFailed", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "trendingAccounts.error.loadingAccountsFailed", showToastr: false)
            }
        }
    }

    private func loadAccounts() async throws -> [Account] {
        switch self.listType {
        case .trending:
            do {
                let accountsFromApi = try await self.client.trends?.accounts()
                return accountsFromApi ?? []
            } catch NetworkError.notSuccessResponse(let response) {
                // TODO: This code can be removed when other Pixelfed server will support trending accounts.
                if response.statusCode() == HTTPStatusCode.notFound {
                    return []
                }

                throw NetworkError.notSuccessResponse(response)
            }
        case .search(let query):
            let results = try await self.client.search?.search(query: query, resultsType: .accounts, limit: 40, page: 1)
            return results?.accounts ?? []
        }
    }
}
