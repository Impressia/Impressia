//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

struct AccountsSectionView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client

    @State private var accounts: [AccountModel] = []
    @State private var dbAccounts: [AccountData] = []

    var body: some View {
        Section("settings.title.accounts") {
            ForEach(self.accounts) { account in
                HStack(alignment: .center) {
                    UsernameRow(accountId: account.id,
                                accountAvatar: account.avatar,
                                accountDisplayName: account.displayName,
                                accountUsername: account.username)
                    Spacer()
                    if self.applicationState.account?.id == account.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(self.applicationState.tintColor.color())
                    }
                }
                .deleteDisabled(self.deleteDisabled(for: account))
            }
            .onDelete(perform: delete)

            NavigationLink(value: RouteurDestinations.signIn) {
                HStack {
                    Text("settings.title.newAccount", comment: "New account")
                    Spacer()
                    Image(systemName: "person.crop.circle.badge.plus")
                }
            }
        }
        .onAppear {
            self.dbAccounts = AccountDataHandler.shared.getAccountsData()
            self.accounts = self.dbAccounts.map({ AccountModel(accountData: $0) })
        }
    }

    private func deleteDisabled(for account: AccountModel) -> Bool {
        self.applicationState.account?.id == account.id && self.accounts.count > 1
    }

    private func delete(at offsets: IndexSet) {
        let accountsToDelete = offsets.map { self.accounts[$0] }
        var shouldClearApplicationState = false

        // Delete from database.
        for account in accountsToDelete {
            // Check if we are deleting active user.
            if account.id == self.applicationState.account?.id {
                shouldClearApplicationState = true
            }

            if let dbAccount = self.dbAccounts.first(where: {$0.id == account.id }) {
                AccountDataHandler.shared.remove(accountData: dbAccount)
            }
        }

        // Delete from local state.
        self.accounts.remove(atOffsets: offsets)

        // When we are deleting active user then we have to switch to sing in view.
        if shouldClearApplicationState {
            // We have to do this after animation of deleting row is ended.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ApplicationSettingsHandler.shared.set(accountId: nil)
                self.applicationState.clearApplicationState()
                self.client.clearAccount()
            }
        }
    }
}
