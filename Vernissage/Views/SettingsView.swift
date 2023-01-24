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
    @State private var appBundleVersion: String?
        
    var body: some View {
        NavigationStack {
            NavigationView {
                List {
                    // Accounts.
                    AccountsSection()
                    
                    // Themes.
                    ThemeSection()
                    
                    // Accents.
                    AccentsSection()
                    
                    // Avatar shapes.
                    AvatarShapesSection()
                    
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
                            Text("\(appVersion ?? String.empty()) (\(appBundleVersion ?? String.empty()))")
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
                    self.appBundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification), perform: { _ in
                    self.theme = applicationState.theme.colorScheme() ?? self.getSystemColorScheme()
                })
                .navigationBarTitle(Text("Settings"), displayMode: .inline)
                .preferredColorScheme(self.theme)
            }
            .withAppRouteur()
        }
        .onChange(of: self.applicationState.theme) { newValue in
            // Change theme of current modal screen (unformtunatelly it's not changed autmatically.
            self.theme = self.applicationState.theme.colorScheme() ?? self.getSystemColorScheme()
        }
    }

    func getSystemColorScheme() -> ColorScheme {
        return UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
    }
}
