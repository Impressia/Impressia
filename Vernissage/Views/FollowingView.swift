//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit

struct FollowingView: View {
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
                        UsernameRow(accountId: account.id,
                                    accountAvatar: account.avatar,
                                    accountDisplayName: account.displayName,
                                    accountUsername: account.acct)
                    }
            }
            
            if allItemsLoaded == false && firstLoadFinished == true {
                HStack {
                    Spacer()
                    LoadingIndicator()
                        .task {
                            self.page = self.page + 1
                            await self.loadAccounts(page: self.page)
                        }
                    Spacer()
                }
                .listRowSeparator(.hidden)
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
        .navigationBarTitle("Following")
        .listStyle(PlainListStyle())
        .task {
            if self.accounts.isEmpty == false {
                return
            }
            
            await self.loadAccounts(page: self.page)
        }
    }
    
    func loadAccounts(page: Int) async {
        do {
            let accountsFromApi = try await AccountService.shared.getFollowing(
                forAccountId: self.accountId,
                andContext: self.applicationState.accountData,
                page: page)
            
            if accountsFromApi.isEmpty || accountsFromApi.count < 10 {
                self.allItemsLoaded = true
            }
            
            await self.downloadAvatars(accounts: accountsFromApi)
            self.accounts.append(contentsOf: accountsFromApi)
            
            self.firstLoadFinished = true
        } catch {
            ErrorService.shared.handle(error, message: "Error during download following from server.", showToastr: true)
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

struct FollowingView_Previews: PreviewProvider {
    static var previews: some View {
        FollowersView(accountId: "")
    }
}
