//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import Nuke
import NukeUI

@main
struct VernissageApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let coreDataHandler = CoreDataHandler.shared

    @StateObject var applicationState = ApplicationState.shared
    @StateObject var client = Client.shared
    @StateObject var routerPath = RouterPath()
    @StateObject var tipsStore = TipsStore()
    
    @State var applicationViewMode: ApplicationViewMode = .loading
    @State var tintColor = ApplicationState.shared.tintColor.color()
    @State var theme = ApplicationState.shared.theme.colorScheme()
    
    let timer = Timer.publish(every: 120, on: .main, in: .common).autoconnect()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $routerPath.path) {
                switch applicationViewMode {
                case .loading:
                    LoadingView()
                        .withAppRouteur()
                        .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
                case .signIn:
                    SignInView { accountData in
                        self.setApplicationState(accountData: accountData)
                    }
                    .withAppRouteur()
                    .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
                case .mainView:
                    MainView()
                        .withAppRouteur()
                        .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
                        .withOverlayDestinations(overlayDestinations: $routerPath.presentedOverlay)
                }
            }
            .environment(\.managedObjectContext, coreDataHandler.container.viewContext)
            .environmentObject(applicationState)
            .environmentObject(client)
            .environmentObject(routerPath)
            .environmentObject(tipsStore)
            .tint(self.tintColor)
            .preferredColorScheme(self.theme)
            .task {
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.secondaryLabel
                
                // Set custom configurations for Nuke image/data loaders.
                self.setImagePipelines()

                // Load user preferences from database.
                self.loadUserPreferences()
                
                // Refresh other access tokens.
                await self.refreshAccessTokens()
                
                // Verify access token correctness.
                let authorizationSession = AuthorizationSession()
                let currentAccount = AccountDataHandler.shared.getCurrentAccountData()
                await AuthorizationService.shared.verifyAccount(session: authorizationSession, currentAccount: currentAccount) { accountData in
                    guard let accountData = accountData else {
                        self.applicationViewMode = .signIn
                        return
                    }
                    
                    self.setApplicationState(accountData: accountData, checkNewPhotos: true)
                }
            }
            .navigationViewStyle(.stack)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    Task {
                        // Refresh indicator of new photos when application is become active.
                        await self.calculateNewPhotosInBackground()
                    }
                }
            }
            .onReceive(timer) { time in
                Task {
                    // Refresh indicator of new photos each two minutes (when application is in the foreground)..
                    await self.calculateNewPhotosInBackground()
                }
            }
            .onChange(of: applicationState.theme) { newValue in
                self.theme = newValue.colorScheme()
            }
            .onChange(of: applicationState.tintColor) { newValue in
                self.tintColor = newValue.color()
            }
            .onChange(of: applicationState.account) { newValue in
                if newValue == nil {
                    self.applicationViewMode = .signIn
                }
            }
        }
    }

    private func setApplicationState(accountData: AccountData, checkNewPhotos: Bool = false) {
        Task { @MainActor in
            let accountModel = AccountModel(accountData: accountData)
            let instance = try? await self.client.instances.instance(url: accountModel.serverUrl)

            // Refresh client state.
            self.client.setAccount(account: accountModel)
            
            // Refresh application state.
            self.applicationState.changeApplicationState(accountModel: accountModel,
                                                         instance: instance,
                                                         lastSeenStatusId: accountData.lastSeenStatusId)
            
            // Change view displayed by application.
            self.applicationViewMode = .mainView
            
            // Check amount of newly added photos.
            if checkNewPhotos {
                await self.calculateNewPhotosInBackground()
            }
        }
    }
    
    private func loadUserPreferences() {
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
        
        self.applicationState.showSensitive = defaultSettings.showSensitive
        self.applicationState.showPhotoDescription = defaultSettings.showPhotoDescription
    }
    
    private func setImagePipelines() {
        let pipeline = ImagePipeline {
            $0.dataLoader =  DataLoader(configuration: {
                // Disable disk caching built into URLSession
                let conf = DataLoader.defaultConfiguration
                conf.urlCache = nil
                return conf
            }())
            
            $0.imageCache = ImageCache.shared
            $0.dataCache = try! DataCache(name: AppConstants.imagePipelineCacheName)
        }
        
        ImagePipeline.shared = pipeline
    }
    
    private func refreshAccessTokens() async {
        let defaultSettings = ApplicationSettingsHandler.shared.getDefaultSettings()
        
        // Run refreshing access tokens once per day.
        guard let refreshTokenDate = Calendar.current.date(byAdding: .day, value: 1, to: defaultSettings.lastRefreshTokens), refreshTokenDate < Date.now else {
            return
        }
    
        // Refresh access tokens.
        await AuthorizationService.shared.refreshAccessTokens()
        
        // Update time when refresh tokens has been updated.
        defaultSettings.lastRefreshTokens = Date.now
        CoreDataHandler.shared.save()
    }
    
    private func calculateNewPhotosInBackground() async {
        if let account = self.applicationState.account {
            self.applicationState.amountOfNewStatuses = await HomeTimelineService.shared.amountOfNewStatuses(for: account)
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
