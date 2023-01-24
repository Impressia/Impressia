//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

@main
struct VernissageApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let coreDataHandler = CoreDataHandler.shared
    @StateObject var applicationState = ApplicationState.shared
    
    @State var applicationViewMode: ApplicationViewMode = .loading
    @State var tintColor = ApplicationState.shared.tintColor.color()
    @State var theme = ApplicationState.shared.theme.colorScheme()
    
    @StateObject private var routerPath = RouterPath()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $routerPath.path) {
                switch applicationViewMode {
                case .loading:
                    LoadingView()
                        .withAppRouteur()
                        .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
                case .signIn:
                    SignInView { viewMode in
                        applicationViewMode = viewMode
                    }
                    .withAppRouteur()
                    .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
                case .mainView:
                    MainView()
                        .withAppRouteur()
                        .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
                }
            }
            .environment(\.managedObjectContext, coreDataHandler.container.viewContext)
            .environmentObject(applicationState)
            .environmentObject(routerPath)
            .tint(self.tintColor)
            .preferredColorScheme(self.theme)
            .task {
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.secondaryLabel
                
                let defaultSettings = ApplicationSettingsHandler.shared.getDefaultSettings()
                
                if let tintColor = TintColor(rawValue: Int(defaultSettings.tintColor)) {
                    self.applicationState.tintColor = tintColor
                    self.tintColor = tintColor.color()
                }
                
                if let theme = Theme(rawValue: Int(defaultSettings.theme)) {
                    self.applicationState.theme = theme
                    self.theme = theme.colorScheme()
                }

                if let avatarShape = AvatarShape(rawValue: Int(defaultSettings.avatarShape)) {
                    self.applicationState.avatarShape = avatarShape
                }
                
                await AuthorizationService.shared.verifyAccount({ accountData in
                    guard let accountData = accountData else {
                        self.applicationViewMode = .signIn
                        return
                    }
                    
                    Task { @MainActor in
                        self.applicationState.accountData = accountData
                    }
                    
                    self.applicationViewMode = .mainView
                })
            }
            .navigationViewStyle(.stack)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                try? HapticService.shared.start()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                HapticService.shared.stop()
            }
            .onChange(of: applicationState.theme) { newValue in
                self.theme = newValue.colorScheme()
            }
            .onChange(of: applicationState.tintColor) { newValue in
                self.tintColor = newValue.color()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
     }
}
