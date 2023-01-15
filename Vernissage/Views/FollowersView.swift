//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit

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
            
            if allItemsLoaded == false && firstLoadFinished == true {
                LoadingIndicator()
                    .task {
                        self.page = self.page + 1
                        await self.loadAccounts(page: self.page)
                    }
                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
            }
        }.overlay {
            if firstLoadFinished == false {
                LoadingIndicator()
            } else {
                if self.accounts.isEmpty {
                    VStack {
                        Image(systemName: "person.3.sequence")
                            .font(.largeTitle)
                            .padding(.bottom, 4)
                        Text("Unfortunately, there is no one here.")
                            .font(.title3)
                    }.foregroundColor(.lightGrayColor)
                }
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
            
            if accountsFromApi.isEmpty || accountsFromApi.count < 10 {
                self.allItemsLoaded = true
                return
            }
            
            await self.downloadAvatars(accounts: accountsFromApi)
            self.accounts.append(contentsOf: accountsFromApi)
        } catch {
            ErrorService.shared.handle(error, message: "Error during download followers from server.", showToastr: true)
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
