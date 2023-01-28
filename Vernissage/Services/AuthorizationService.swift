//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

/// Srvice responsible for login user into the Pixelfed account.
public class AuthorizationService {
    public static let shared = AuthorizationService()
    private init() { }
    
    /// Access token verification.
    public func verifyAccount(_ result: @escaping (AccountData?) -> Void) async {
        let currentAccount = AccountDataHandler.shared.getCurrentAccountData()
        
        // When we dont have even one account stored in database then we have to ask user to enter server and sign in.
        guard let currentAccount, let accessToken = currentAccount.accessToken else {
            result(nil)
            return
        }
        
        // When we have at least one account then we have to verify access token.
        let client = MastodonClient(baseURL: currentAccount.serverUrl).getAuthenticated(token: accessToken)

        do {
            let account = try await client.verifyCredentials()
            try await self.update(account: currentAccount, basedOn: account)
            result(currentAccount)
        } catch {
            do {
                try await self.refreshCredentials(for: currentAccount)
                result(currentAccount)
            } catch {
                ErrorService.shared.handle(error, message: "Issues during refreshing credentials.", showToastr: true)
            }
        }
    }
    
    /// Sign in to the Pixelfed server.
    public func sign(in serverAddress: String, _ result: @escaping (AccountData?) -> Void) async throws {
        let baseUrl = URL(string: serverAddress)!
        let client = MastodonClient(baseURL: baseUrl)
        
        // Verify address.
        let instanceInformation = try await client.readInstanceInformation()

        // Create application (we will get clientId amd clientSecret).
        let oAuthApp = try await client.createApp(
            named: "Vernissage",
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
        let accountData = AccountDataHandler.shared.createAccountDataEntity()

        accountData.id = account.id
        accountData.username = account.username
        accountData.acct = account.acct
        accountData.displayName = account.displayNameWithoutEmojis
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
        accountData.clientVapidKey = oAuthApp.vapidKey ?? String.empty()
        accountData.accessToken = oAuthSwiftCredential.oauthToken
        
        // Download avatar image.
        if let avatarUrl = account.avatar {
            do {
                let avatarData = try await RemoteFileService.shared.fetchData(url: avatarUrl)
                accountData.avatarData = avatarData
            }
            catch {
                ErrorService.shared.handle(error, message: "Avatar has not been downloaded.")
            }
        }
        
        // Set newly created account as current.
        let defaultSettings = ApplicationSettingsHandler.shared.getDefaultSettings()
        defaultSettings.currentAccount = accountData.id
        
        // Save account data in database and in application state.
        CoreDataHandler.shared.save()
        
        // Return account data.
        result(accountData)
    }
    
    private func refreshCredentials(for accountData: AccountData) async throws {
        let client = MastodonClient(baseURL: accountData.serverUrl)

        // Create application (we will get clientId amd clientSecret).
        let oAuthApp = Application(clientId: accountData.clientId, clientSecret: accountData.clientSecret)
        
        // Authorize a user (browser, we will get clientCode).
        let oAuthSwiftCredential = try await client.authenticate(app: oAuthApp, scope: Scopes(["read", "write", "follow", "push"]))
        
        // Get authenticated client.
        let authenticatedClient = client.getAuthenticated(token: oAuthSwiftCredential.oauthToken)
        
        // Get account information from server.
        let account = try await authenticatedClient.verifyCredentials()
        try await self.update(account: accountData, basedOn: account, accessToken: oAuthSwiftCredential.oauthToken)
    }
    
    private func update(account dbAccount: AccountData, basedOn account: Account, accessToken: String? = nil) async throws {
        dbAccount.username = account.username
        dbAccount.acct = account.acct
        dbAccount.displayName = account.displayName
        dbAccount.note = account.note
        dbAccount.url = account.url
        dbAccount.avatar = account.avatar
        dbAccount.header = account.header
        dbAccount.locked = account.locked
        dbAccount.createdAt = account.createdAt
        dbAccount.followersCount = Int32(account.followersCount)
        dbAccount.followingCount = Int32(account.followingCount)
        dbAccount.statusesCount = Int32(account.statusesCount)
        
        if accessToken != nil {
            dbAccount.accessToken = accessToken
        }
        
        // Download avatar image.
        if let avatarUrl = account.avatar {
            do {
                let avatarData = try await RemoteFileService.shared.fetchData(url: avatarUrl)
                dbAccount.avatarData = avatarData
            }
            catch {
                ErrorService.shared.handle(error, message: "Avatar has not been downloaded.")
            }
        }
        
        // We have to be sure that account id is saved as default account.
        let defaultSettings = ApplicationSettingsHandler.shared.getDefaultSettings()
        defaultSettings.currentAccount = dbAccount.id
        
        // Save account data in database and in application state.
        CoreDataHandler.shared.save()
    }
}
