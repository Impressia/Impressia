//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI

struct AccountsSection: View {
    @State private var accounts: [AccountData] = []
    
    var body: some View {
        Section("Accounts") {
            ForEach(self.accounts) { account in
                UsernameRow(accountAvatar: account.avatar,
                            accountDisplayName: account.displayName,
                            accountUsername: account.username,
                            cachedAvatar: CacheAvatarService.shared.getImage(for: account.id))
            }
            
            NavigationLink(destination: SignInView()) {
                HStack {
                    Text("New account")
                    Spacer()
                    Image(systemName: "person.crop.circle.badge.plus")
                }
            }
        }
        .task {
            self.accounts = AccountDataHandler.shared.getAccountsData()
        }
    }
}

struct AccountsSection_Previews: PreviewProvider {
    static var previews: some View {
        AccountsSection()
    }
}
