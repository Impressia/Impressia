//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct AccountsSection: View {
    @EnvironmentObject var applicationState: ApplicationState

    @State private var accounts: [AccountData] = []
    
    var body: some View {
        Section("Accounts") {
            ForEach(self.accounts) { account in
                HStack(alignment: .center) {
                    UsernameRow(accountId: account.id,
                                accountAvatar: account.avatar,
                                accountDisplayName: account.displayName,
                                accountUsername: account.username)
                    Spacer()
                    if self.applicationState.accountData?.id == account.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(self.applicationState.tintColor.color())
                    }
                }
                .deleteDisabled(self.applicationState.accountData?.id == account.id)
            }
            .onDelete(perform: delete)
            
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
    
    func delete(at offsets: IndexSet) {
        let accountsToDelete = offsets.map { self.accounts[$0] }
        for account in accountsToDelete {
            AccountDataHandler.shared.remove(accountData: account)
        }
    }
}
