//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonSwift

@main
struct VernissageApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let coreDataHandler = CoreDataHandler.shared
    let applicationState = ApplicationState.shared
    
    @State var applicationViewMode: ApplicationViewMode = .loading
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                switch applicationViewMode {
                case .loading:
                    Text("Loading")
                case .signIn:
                    SignInView { viewMode in
                        applicationViewMode = viewMode
                    }
                    .environment(\.managedObjectContext, coreDataHandler.container.viewContext)
                    .environmentObject(applicationState)
                case .mainView:
                    MainView()
                        .environment(\.managedObjectContext, coreDataHandler.container.viewContext)
                        .environmentObject(applicationState)
                }
            }
            .task {
                let accountDataHandler = AccountDataHandler()
                let currentAccount = accountDataHandler.getCurrentAccountData()
                
                // When we dont have even one account stored in database then we have to ask user to enter server and sign in.
                guard let accountData = currentAccount, let accessToken = accountData.accessToken else {
                    self.applicationViewMode = .signIn
                    return
                }
                
                // When we have at least one account then we have to verify access token.
                let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)

                do {
                    let account = try await client.verifyCredentials()
                    try await self.updateAccount(accountData: accountData, account: account)
                    
                    self.applicationViewMode = .mainView
                    self.applicationState.accountData = accountData
                } catch {
                    do {
                        try await self.refreshCredentials(accountData: accountData)
                        
                        self.applicationViewMode = .mainView
                        self.applicationState.accountData = accountData
                    } catch {
                        // TODO: show information to the user.
                        print("Cannot refresh credentials!!!")
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
    }
    
    private func refreshCredentials(accountData: AccountData) async throws {
        let client = MastodonClient(baseURL: accountData.serverUrl)

        // Create application (we will get clientId amd clientSecret).
        let oAuthApp = App(clientId: accountData.clientId, clientSecret: accountData.clientSecret)
        
        // Authorize a user (browser, we will get clientCode).
        let oAuthSwiftCredential = try await client.authenticate(app: oAuthApp, scope: Scopes(["read", "write", "follow", "push"]))
        
        // Get authenticated client.
        let authenticatedClient = client.getAuthenticated(token: oAuthSwiftCredential.oauthToken)
        
        // Get account information from server.
        let account = try await authenticatedClient.verifyCredentials()
        try await self.updateAccount(accountData: accountData, account: account, accessToken: oAuthSwiftCredential.oauthToken)

        self.applicationState.accountData = accountData
        self.applicationViewMode = .mainView
    }
    
    private func updateAccount(accountData: AccountData, account: Account, accessToken: String? = nil) async throws {
        accountData.username = account.username
        accountData.acct = account.acct
        accountData.displayName = account.displayName
        accountData.note = account.note
        accountData.url = account.url
        accountData.avatar = account.avatar
        accountData.header = account.header
        accountData.locked = account.locked
        accountData.createdAt = account.createdAt
        accountData.followersCount = Int32(account.followersCount)
        accountData.followingCount = Int32(account.followingCount)
        accountData.statusesCount = Int32(account.statusesCount)
        
        if accessToken != nil {
            accountData.accessToken = accessToken
        }
        
        // Download avatar image.
        if let avatarUrl = account.avatar {
            do {
                let avatarData = try await RemoteFileService.shared.fetchData(url: avatarUrl)
                accountData.avatarData = avatarData
            }
            catch {
                print("Avatar has not been downloaded")
            }
        }
        
        // We have to be sure that account id is saved as default account.
        let applicationSettingsHandler = ApplicationSettingsHandler()
        let defaultSettings = applicationSettingsHandler.getDefaultSettings()
        defaultSettings.currentAccount = accountData.id
        
        // Save account data in database and in application state.
        try self.coreDataHandler.container.viewContext.save()
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
