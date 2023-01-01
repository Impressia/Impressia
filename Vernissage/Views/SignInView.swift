//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonSwift

struct SignInView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var applicationState: ApplicationState

    @State private var serverAddress: String = ""
    
    var onSignInStateChenge: (_ applicationViewMode: ApplicationViewMode) -> Void?
    
    var body: some View {
        VStack {
            HStack {
                TextField(
                    "Server address",
                    text: $serverAddress
                )
                .onSubmit {
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                
                Button("Go") {
                    Task {
                        try await self.signIn()
                    }
                }
            }
        }
        .padding()
        .navigationBarTitle("Sign in to Pixelfed")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func signIn() async throws {
        let baseUrl = URL(string: serverAddress)!
        let client = MastodonClient(baseURL: baseUrl)
        
        // Verify address.
        let instanceInformation = try await client.readInstanceInformation()
        print(instanceInformation)

        // Create application (we will get clientId amd clientSecret).
        let oAuthApp = try await client.createApp(
            named: "Photofed",
            redirectUri: "oauth-vernissage://oauth-callback/mastodon",
            scopes: Scopes(["read", "write", "follow", "push"]),
            website: baseUrl)
        
        // Authorize a user (browser, we will get clientCode).
        let oAuthSwiftCredential = try await client.authenticate(
            app: oAuthApp,
            scope: Scopes(["read", "write", "follow", "push"]))
        
        // Get authenticated client.
        let authenticatedClient = client.getAuthenticated(token: oAuthSwiftCredential.oauthToken)
        
        // Get account information from server.
        let account = try await authenticatedClient.verifyCredentials()
        
        // Create account object in database.
        let accountDataHandler = AccountDataHandler()
        let accountData = accountDataHandler.createAccountDataEntity()

        accountData.id = account.id
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
        
        accountData.serverUrl = baseUrl
        accountData.clientId = oAuthApp.clientId
        accountData.clientSecret = oAuthApp.clientSecret
        accountData.clientVapidKey = oAuthApp.vapidKey ?? ""
        accountData.accessToken = oAuthSwiftCredential.oauthToken
        
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
        
        // Set newly created account as current.
        let applicationSettingsHandler = ApplicationSettingsHandler()
        let defaultSettings = applicationSettingsHandler.getDefaultSettings()
        defaultSettings.currentAccount = accountData.id
        
        // Save account data in database and in application state.
        try self.viewContext.save()
        
        self.applicationState.accountData = accountData
        self.onSignInStateChenge(.mainView)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView { applicationViewMode in }
    }
}
