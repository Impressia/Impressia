//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonSwift

struct FollowersView: View {
    @EnvironmentObject var applicationState: ApplicationState

    @State var accountId: String
    @State private var accounts: [Account] = []
    @State private var page = 1
    @State private var allItemsLoaded = false
    @State private var firstLoadFinished = false
    
    var body: some View {
        List {
            ForEach(accounts, id: \.id) { account in
                NavigationLink(destination: UserProfileView(
                    accountId: account.id,
                    accountDisplayName: account.displayName,
                    accountUserName: account.acct)
                    .environmentObject(applicationState)) {
                        UsernameRow(accountAvatar: account.avatar,
                                    accountDisplayName: account.displayName,
                                    accountUsername: account.acct,
                                    cachedAvatar: CacheAvatarService.shared.getImage(for: account.id))
                    }
            }
            
            if allItemsLoaded == false && firstLoadFinished {
                HStack(alignment: .center) {
                    Spacer()
                    LoadingIndicator()
                        .onAppear {
                            Task {
                                self.page = self.page + 1
                                await self.loadAccounts(page: self.page)
                            }
                        }
                    Spacer()
                }
            }
        }.overlay {
            if firstLoadFinished == false {
                LoadingIndicator()
            }
        }
        .navigationBarTitle("Followers")
        .listStyle(PlainListStyle())
        .task {
            if self.accounts.isEmpty == false {
                return
            }
            
            await self.loadAccounts(page: self.page)
            self.firstLoadFinished = true
        }
    }
    
    func loadAccounts(page: Int) async {
        do {
            let accountsFromApi = try await AccountService.shared.getFollowers(
                forAccountId: self.accountId,
                andContext: self.applicationState.accountData,
                page: page)
            
            if accountsFromApi.isEmpty {
                self.allItemsLoaded = true
                return
            }
            
            await self.downloadAvatars(accounts: accountsFromApi)
            self.accounts.append(contentsOf: accountsFromApi)
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func downloadAvatars(accounts: [Account]) async {
        await withTaskGroup(of: Void.self) { group in
            for account in accounts {
                group.addTask { await CacheAvatarService.shared.downloadImage(for: account.id, avatarUrl: account.avatar) }
            }
        }
    }
}

struct FollowersView_Previews: PreviewProvider {
    static var previews: some View {
        FollowersView(accountId: "")
    }
}
