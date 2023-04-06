//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
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
                    SignInView { accountModel in
                        self.setApplicationState(accountModel: accountModel)
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
                await self.onApplicationStart()
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
            .onReceive(timer) { _ in
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
            .onChange(of: applicationState.showStatusId) { newValue in
                if let statusId = newValue {
                    self.routerPath.navigate(to: .status(id: statusId))
                    self.applicationState.showStatusId = nil
                }
            }
        }
    }

    @MainActor
    private func onApplicationStart() async {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.white.withAlphaComponent(0.7)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)

        // Set custom configurations for Nuke image/data loaders.
        self.setImagePipelines()

        // Load user preferences from database.
        self.loadUserPreferences()

        // Refresh other access tokens.
        await self.refreshAccessTokens()

        // When user doesn't exists then we have to open sign in view.
        guard let currentAccount = AccountDataHandler.shared.getCurrentAccountData() else {
            self.applicationViewMode = .signIn
            return
        }

        // Create model based on core data entity.
        let accountModel = AccountModel(accountData: currentAccount)

        // Verify access token correctness.
        let authorizationSession = AuthorizationSession()
        await AuthorizationService.shared.verifyAccount(session: authorizationSession, accountModel: accountModel) { signedInAccountModel in
            guard let signedInAccountModel else {
                self.applicationViewMode = .signIn
                return
            }

            self.setApplicationState(accountModel: signedInAccountModel, checkNewPhotos: true)
        }
    }

    private func setApplicationState(accountModel: AccountModel, checkNewPhotos: Bool = false) {
        Task { @MainActor in
            let instance = try? await self.client.instances.instance(url: accountModel.serverUrl)

            // Refresh client state.
            self.client.setAccount(account: accountModel)

            // Refresh application state.
            self.applicationState.changeApplicationState(accountModel: accountModel,
                                                         instance: instance,
                                                         lastSeenStatusId: accountModel.lastSeenStatusId)

            // Change view displayed by application.
            self.applicationViewMode = .mainView

            // Check amount of newly added photos.
            if checkNewPhotos {
                await self.calculateNewPhotosInBackground()
            }
        }
    }

    private func loadUserPreferences() {
        let defaultSettings = ApplicationSettingsHandler.shared.get()

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

        self.applicationState.activeIcon = defaultSettings.activeIcon
        self.applicationState.showSensitive = defaultSettings.showSensitive
        self.applicationState.showPhotoDescription = defaultSettings.showPhotoDescription

        self.applicationState.hapticTabSelectionEnabled = defaultSettings.hapticTabSelectionEnabled
        self.applicationState.hapticRefreshEnabled = defaultSettings.hapticRefreshEnabled
        self.applicationState.hapticButtonPressEnabled = defaultSettings.hapticButtonPressEnabled
        self.applicationState.hapticAnimationEnabled = defaultSettings.hapticAnimationEnabled
        self.applicationState.hapticNotificationEnabled = defaultSettings.hapticNotificationEnabled
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
            if let dataCache = try? DataCache(name: AppConstants.imagePipelineCacheName) {
                $0.dataCache = dataCache
            }
        }

        ImagePipeline.shared = pipeline
    }

    private func refreshAccessTokens() async {
        let defaultSettings = ApplicationSettingsHandler.shared.get()

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
