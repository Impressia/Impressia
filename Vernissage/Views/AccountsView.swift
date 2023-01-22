//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit

struct AccountsView: View {
    public enum ListType {
        case followers
        case following
        case reblogged
        case favourited
    }
    
    @EnvironmentObject var applicationState: ApplicationState

    @State var entityId: String
    @State var listType: ListType

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
                                    accountDisplayName: account.displayNameWithoutEmojis,
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
        .navigationBarTitle(self.getTitle())
        .listStyle(PlainListStyle())
        .task {
            if self.accounts.isEmpty == false {
                return
            }
            
            await self.loadAccounts(page: self.page)
        }
    }
    
    private func loadAccounts(page: Int) async {
        do {
            let accountsFromApi = try await self.loadFromApi()
            if accountsFromApi.isEmpty || accountsFromApi.count < 10 {
                self.allItemsLoaded = true
            }
            
            await self.downloadAvatars(accounts: accountsFromApi)
            self.accounts.append(contentsOf: accountsFromApi)
            
            self.firstLoadFinished = true
        } catch {
            ErrorService.shared.handle(error, message: "Error during download followers from server.", showToastr: !Task.isCancelled)
        }
    }
    
    private func getTitle() -> String {
        switch self.listType {
        case .followers:
            return "Followers"
        case .following:
            return "Following"
        case .favourited:
            return "Favourited by"
        case .reblogged:
            return "Reboosted by"
        }
    }
    
    private func loadFromApi() async throws -> [Account] {
        switch self.listType {
        case .followers:
            return try await AccountService.shared.followers(
                forAccountId: self.entityId,
                andContext: self.applicationState.accountData,
                page: page)
        case .following:
            return try await AccountService.shared.following(
                forAccountId: self.entityId,
                andContext: self.applicationState.accountData,
                page: page)
        case .favourited:
            return try await StatusService.shared.favouritedBy(
                statusId: self.entityId,
                andContext: self.applicationState.accountData,
                page: page)
        case .reblogged:
            return try await StatusService.shared.rebloggedBy(
                statusId: self.entityId,
                andContext: self.applicationState.accountData,
                page: page)
        }
    }
    
    private func downloadAvatars(accounts: [Account]) async {
        await withTaskGroup(of: Void.self) { group in
            for account in accounts {
                group.addTask { await CacheAvatarService.shared.downloadImage(for: account.id, avatarUrl: account.avatar) }
            }
        }
    }
}
