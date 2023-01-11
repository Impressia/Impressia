//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.dismiss) private var dismiss
    
    @State var accounts: [AccountData] = []
    
    var body: some View {
        NavigationView {
            List {
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

                Section("General") {
                    Text("Accent")
                }
                
                Section("About") {
                    Text("Website")
                    Text("License")
                }
            }
            .frame(alignment: .topLeading)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .task {
                self.accounts = AccountDataHandler.shared.getAccountsData()
            }
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
