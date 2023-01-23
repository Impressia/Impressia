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
                UsernameRow(accountId: account.id,
                            accountAvatar: account.avatar,
                            accountDisplayName: account.displayName,
                            accountUsername: account.username)
            }
            
            NavigationLink(value: RouteurDestinations.signIn) {
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
