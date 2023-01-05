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
    
    var body: some View {
        List(accounts, id: \.id) { account in
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

            if allItemsLoaded == false && accounts.last?.id == account.id {
                HStack(alignment: .center) {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            Task {
                                self.page = self.page + 1
                                await self.loadAccounts(page: self.page)
                            }
                        }
                    Spacer()
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
            
            for account in accountsFromApi {
                guard let avatarUrl = account.avatar else {
                    continue
                }

                do {
                    if let avatarData = try await RemoteFileService.shared.fetchData(url: avatarUrl) {
                        CacheAvatarService.shared.addImage(for: account.id, data: avatarData)
                    }
                } catch {
                    print("Error \(error.localizedDescription)")
                }
            }
            
            self.accounts.append(contentsOf: accountsFromApi)
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
}

struct FollowersView_Previews: PreviewProvider {
    static var previews: some View {
        FollowersView(accountId: "")
    }
}
