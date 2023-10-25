//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Nuke
import NukeUI
import ClientKit
import EnvironmentKit
import WidgetKit
import SwiftData
import TipKit
import OSLog
import BackgroundTasks

@main
struct VernissageApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var phase

    @State var applicationState = ApplicationState.shared
    @State var client = Client.shared
    @State var routerPath = RouterPath()
    @State var tipsStore = TipsStore()

    @State var applicationViewMode: ApplicationViewMode = .loading
    @State var tintColor = ApplicationState.shared.tintColor.color()
    @State var theme = ApplicationState.shared.theme.colorScheme()

    let modelContainer = SwiftDataHandler.shared.sharedModelContainer
    let timer = Timer.publish(every: 120, on: .main, in: .common).autoconnect()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
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
                        .withAlertDestinations(alertDestinations: $routerPath.presentedAlert)
                }
            }
            .modelContainer(modelContainer)
            .environment(applicationState)
            .environment(client)
            .environment(routerPath)
            .environment(tipsStore)
            .tint(self.tintColor)
            .preferredColorScheme(self.theme)
            .task {
                await self.onApplicationStart()
            }
            .onReceive(timer) { _ in
                Task {
                    // Refresh indicator of new photos and new notifications each two minutes (when application is in the foreground)..
                    _ = await (self.calculateNewPhotosInBackground(), self.calculateNewNotificationsInBackground())
                }
            }
            .onChange(of: applicationState.theme) { oldValue, newValue in
                self.theme = newValue.colorScheme()
            }
            .onChange(of: applicationState.tintColor) { oldValue, newValue in
                self.tintColor = newValue.color()
            }
            .onChange(of: applicationState.account) { oldValue, newValue in
                if newValue == nil {
                    self.applicationViewMode = .signIn
                }
            }
            .onChange(of: applicationState.showStatusId) { oldValue, newValue in
                if let statusId = newValue {
                    self.routerPath.navigate(to: .status(id: statusId))
                    self.applicationState.showStatusId = nil
                }
            }
            .onChange(of: applicationState.showAccountId) { oldValue, newValue in
                if let accountId = newValue {
                    self.routerPath.navigate(to: .userProfile(accountId: accountId, accountDisplayName: nil, accountUserName: ""))
                    self.applicationState.showAccountId = nil
                }
            }
        }
        .onChange(of: phase) { oldValue, newValue in
            switch newValue {
            case .background:
                scheduleAppRefresh()
            case .active:
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    Task {
                        // Refresh indicator of new photos and new statuses when application is become active.
                        _ = await (self.calculateNewPhotosInBackground(), self.calculateNewNotificationsInBackground())
                    }
                }

                // Reload widget content when application become active.
                WidgetCenter.shared.reloadAllTimelines()
            default: break
            }
        }
        .backgroundTask(.appRefresh(AppConstants.backgroundFetcherName)) {
            await self.setBadgeCount()
        }
    }

    @MainActor
    private func onApplicationStart() async {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.white.withAlphaComponent(0.7)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)

        // Configure TipKit.
        try? Tips.configure([.displayFrequency(.daily), .datastoreLocation(.applicationDefault)])
        
        // Set custom configurations for Nuke image/data loaders.
        self.setImagePipelines()

        // Load user preferences from database.
        self.loadUserPreferences()

        // Refresh other access tokens.
        await self.refreshAccessTokens()

        // When user doesn't exists then we have to open sign in view.
        let modelContext = self.modelContainer.mainContext
        guard let currentAccount = AccountDataHandler.shared.getCurrentAccountData(modelContext: modelContext) else {
            self.applicationViewMode = .signIn
            return
        }
        
        // Create model based on core data entity.
        let accountModel = currentAccount.toAccountModel()

        // Verify access token correctness.
        let authorizationSession = AuthorizationSession()
        await AuthorizationService.shared.verifyAccount(session: authorizationSession,
                                                        accountModel: accountModel,
                                                        modelContext: modelContext) { signedInAccountModel in
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
                                                         lastSeenStatusId: accountModel.lastSeenStatusId,
                                                         lastSeenNotificationId: accountModel.lastSeenNotificationId)

            // Change view displayed by application.
            self.applicationViewMode = .mainView

            // Check amount of newly added photos.
            if checkNewPhotos {
                _ = await (self.calculateNewPhotosInBackground(), self.calculateNewNotificationsInBackground())
            }
        }
    }

    private func loadUserPreferences() {
        let modelContext =  self.modelContainer.mainContext
        ApplicationSettingsHandler.shared.update(applicationState: self.applicationState, modelContext: modelContext)

        self.tintColor = self.applicationState.tintColor.color()
        self.theme = self.applicationState.theme.colorScheme()
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
        let modelContext =  self.modelContainer.mainContext
        let defaultSettings = ApplicationSettingsHandler.shared.get(modelContext: modelContext)

        // Run refreshing access tokens once per day.
        guard let refreshTokenDate = Calendar.current.date(byAdding: .day, value: 1, to: defaultSettings.lastRefreshTokens), refreshTokenDate < Date.now else {
            return
        }

        // Refresh access tokens.
        await AuthorizationService.shared.refreshAccessTokens(modelContext: modelContext)

        // Update time when refresh tokens has been updated.
        defaultSettings.lastRefreshTokens = Date.now
        try? modelContext.save()
    }

    private func calculateNewPhotosInBackground() async {
        let modelContext = self.modelContainer.mainContext

        self.applicationState.amountOfNewStatuses = await HomeTimelineService.shared.amountOfNewStatuses(
            includeReblogs: self.applicationState.showReboostedStatuses,
            hideStatusesWithoutAlt: self.applicationState.hideStatusesWithoutAlt,
            modelContext: modelContext
        )
    }
    
    private func calculateNewNotificationsInBackground() async {
        Logger.main.info("Calculating new notifications started.")

        let modelContext = self.modelContainer.mainContext
        let amountOfNewNotifications = await NotificationsService.shared.amountOfNewNotifications(modelContext: modelContext)
        self.applicationState.amountOfNewNotifications = amountOfNewNotifications

        do {
            try await NotificationsService.shared.setBadgeCount(amountOfNewNotifications, modelContext: modelContext)
            Logger.main.info("New notifications (\(amountOfNewNotifications)) calculated successfully.")
        } catch {
            Logger.main.error("Error ['Set badge count failed']: \(error.localizedDescription)")
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: AppConstants.backgroundFetcherName)
        request.earliestBeginDate = .now.addingTimeInterval(20 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.main.info("Background task scheduled successfully.")
        } catch {
            Logger.main.error("Error ['Registering background task failed']: \(error.localizedDescription)")
        }
    }
    
    private func setBadgeCount() async {
        scheduleAppRefresh()
        await self.calculateNewNotificationsInBackground()
    }
}
