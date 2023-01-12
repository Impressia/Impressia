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
    @State private var matchSystemTheme = true
    
    var onTintChange: ((TintColor) -> Void)?
    
    let accentColors1: [TintColor] = [.accentColor1, .accentColor2, .accentColor3, .accentColor4, .accentColor5]
    let accentColors2: [TintColor] = [.accentColor6, .accentColor7, .accentColor8, .accentColor9, .accentColor10]
    
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

                Section("Theme") {
                    Toggle("Match system", isOn: $matchSystemTheme)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    Text("Light")
                    Text("Dark")
                }
                
                Section("Accent") {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            ForEach(accentColors1, id: \.self) { color in
                                ZStack {
                                    Circle()
                                        .fill(color.color())
                                        .frame(width: 36, height: 36)
                                        .onTapGesture {
                                            self.applicationState.tintColor = color
                                            ApplicationSettingsHandler.shared.setDefaultTintColor(tintColor: color)
                                            self.onTintChange?(color)
                                        }
                                    if color == self.applicationState.tintColor {
                                        Image(systemName: "checkmark")
                                            .tint(Color.mainTextColor)
                                            .fontWeight(.bold)
                                    }
                                }
                                
                                if color != accentColors1.last {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.vertical, 8)
                         
                        HStack(alignment: .center) {
                            ForEach(accentColors2, id: \.self) { color in
                                ZStack {
                                    Circle()
                                        .fill(color.color())
                                        .frame(width: 36, height: 36)
                                        .onTapGesture {
                                            self.applicationState.tintColor = color
                                            ApplicationSettingsHandler.shared.setDefaultTintColor(tintColor: color)
                                            self.onTintChange?(color)
                                        }
                                    if color == self.applicationState.tintColor {
                                        Image(systemName: "checkmark")
                                            .tint(Color.mainTextColor)
                                            .fontWeight(.bold)
                                    }
                                }
                                
                                if color != accentColors2.last {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Other") {
                    Text("Third party") // Link to dependeinces
                    Text("Report a bug")
                    Text("Follow me on Mastodon")
                }
                
                Section() {
                    Text("Version") // Link to dependeinces
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
