//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import PixelfedKit
import Foundation

struct TrendingAccountsView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath

    @State private var accounts: [Account] = []
    @State private var state: ViewState = .loading
    
    var body: some View {
        self.mainBody()
            .navigationTitle("Tags")
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
                NoDataView(imageSystemName: "person.3.sequence", text: "Unfortunately, there is no one here.")
            } else {
                List {
                    ForEach(self.accounts, id: \.id) { account in
                        Section {
                            AccountImagesGridView(account: account)
                        } header: {
                            HStack {
                                UsernameRow(
                                    accountId: account.id,
                                    accountAvatar: account.avatar,
                                    accountDisplayName: account.displayNameWithoutEmojis,
                                    accountUsername: account.acct)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                }
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
    
    private func loadData() async {
        do {
            try await self.loadAccounts()
            self.state = .loaded
        } catch NetworkError.notSuccessResponse(let response) {
            // TODO: This code can be removed when other Pixelfed server will support trending accounts.
            if response.statusCode() == HTTPStatusCode.notFound {
                self.accounts = []
                self.state = .loaded
            }
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "Accounts not retrieved.", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "Accounts not retrieved.", showToastr: false)
            }
        }
    }
    
    private func loadAccounts() async throws {
        let accountsFromApi = try await self.client.trends?.accounts()
        self.accounts = accountsFromApi ?? []
    }
}
