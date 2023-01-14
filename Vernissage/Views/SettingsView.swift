//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var theme: ColorScheme?
    @State private var appVersion: String?
    
    var onTintChange: ((TintColor) -> Void)?
    var onThemeChange: ((Theme) -> Void)?
        
    var body: some View {
        NavigationView {
            List {
                // Accounts.
                AccountsSection()
                
                // Themes.
                ThemeSection { theme in
                    changeTheme(theme: theme)
                }
                
                // Accents.
                AccentsSection { color in
                    self.onTintChange?(color)
                }
                
                // Other.
                Section("Other") {
                    Text("Third party") // Link to dependeinces
                    Text("Report a bug")
                    Text("Follow me on Mastodon")
                }
                
                // Version.
                Section() {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion ?? String.empty())
                            .foregroundColor(.accentColor)
                    }
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
                self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification), perform: { _ in
                self.theme = applicationState.theme.colorScheme() ?? self.getSystemColorScheme()
            })
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .preferredColorScheme(self.theme)
        }
    }
        
    private func changeTheme(theme: Theme) {
        // Change theme of current modal screen (unformtunatelly it's not changed autmatically_
        self.theme = theme.colorScheme() ?? self.getSystemColorScheme()
        
        self.applicationState.theme = theme
        ApplicationSettingsHandler.shared.setDefaultTheme(theme: theme)
        onThemeChange?(theme)
    }
    
    func getSystemColorScheme() -> ColorScheme {
        return UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
