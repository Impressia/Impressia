//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var routerPath: RouterPath
    @EnvironmentObject var tipsStore: TipsStore

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
                    AccountsSectionView()
                                
                    // General.
                    GeneralSectionView()
                    
                    // Accents.
                    AccentsSectionView()
                    
                    // Avatar shapes.
                    AvatarShapesSectionView()
                    
                    // Media settings view.
                    MediaSettingsView()
                    
                    // Haptics.
                    HapticsSectionView()
                    
                    // Support.
                    SupportView()
                    
                    // Other.
                    OtherSectionView()
                    
                    // Version.
                    self.version()
                }
                .frame(alignment: .topLeading)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(NSLocalizedString("settings.title.close", comment: "Close"), role: .cancel) {
                            self.dismiss()
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
                .navigationTitle("settings.navigationBar.title")
                .navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(self.theme)
            }
            .withAppRouteur()
            .withOverlayDestinations(overlayDestinations: $routerPath.presentedOverlay)
        }
        .onChange(of: self.applicationState.theme) { newValue in
            // Change theme of current modal screen (unformtunatelly it's not changed autmatically.
            self.theme = self.applicationState.theme.colorScheme() ?? self.getSystemColorScheme()
        }
        .onChange(of: applicationState.account) { newValue in
            if newValue == nil {
                self.dismiss()
            }
        }
        .onChange(of: tipsStore.status) { status in
            if status == .successful {
                withAnimation(.spring()) {
                    self.routerPath.presentedOverlay = .successPayment
                    self.tipsStore.reset()
                }
            }
        }
        .alert(isPresented: $tipsStore.hasError, error: tipsStore.error) { }
    }
    
    @ViewBuilder
    private func version() -> some View {
        Section() {
            HStack {
                Text("settings.title.version", comment: "Version")
                Spacer()
                Text("\(appVersion ?? String.empty()) (\(appBundleVersion ?? String.empty()))")
                    .foregroundColor(.accentColor)
            }
        }
    }

    private func getSystemColorScheme() -> ColorScheme {
        return UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
    }
}
