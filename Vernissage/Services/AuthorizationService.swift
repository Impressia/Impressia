//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit
import ClientKit
import CoreData
import AuthenticationServices
import ServicesKit
import EnvironmentKit

/// Srvice responsible for login user into the Pixelfed account.
public class AuthorizationService {
    public static let shared = AuthorizationService()
    private init() { }

    /// Access token verification.
    public func verifyAccount(session: AuthorizationSession, accountModel: AccountModel, _ result: @escaping (AccountModel?) -> Void) async {
        // When we dont have even one account stored in database then we have to ask user to enter server and sign in.
        guard let accessToken = accountModel.accessToken else {
            result(nil)
            return
        }

        // When we have at least one account then we have to verify access token.
        let client = PixelfedClient(baseURL: accountModel.serverUrl).getAuthenticated(token: accessToken)

        do {
            let account = try await client.verifyCredentials()
            let signedInAccountModel = await self.update(accountId: accountModel.id,
                                                         basedOn: account,
                                                         accessToken: accessToken,
                                                         refreshToken: accountModel.refreshToken)

            result(signedInAccountModel)
        } catch {
            do {
                let signedInAccountModel = try await self.refreshCredentials(for: accountModel, presentationContextProvider: session)
                result(signedInAccountModel)
            } catch {
                ErrorService.shared.handle(error, message: "global.error.refreshingCredentialsTitle")
                ToastrService.shared.showError(title: "global.error.refreshingCredentialsTitle",
                                               subtitle: NSLocalizedString("global.error.refreshingCredentialsSubtitle", comment: ""))
                result(nil)
            }
        }
    }

    /// Sign in to the Pixelfed server.
    public func sign(in serverAddress: String, session: AuthorizationSession, _ result: @escaping (AccountModel) -> Void) async throws {

        guard let baseUrl = URL(string: serverAddress) else {
            throw AuthorisationError.badServerUrl
        }

        let client = PixelfedClient(baseURL: baseUrl)

        // Verify address.
        _ = try await client.readInstanceInformation()

        // Create application (we will get clientId and clientSecret).
        let oAuthApp = try await client.createApp(
            named: AppConstants.oauthApplicationName,
            redirectUri: AppConstants.oauthRedirectUri,
            scopes: Scopes(AppConstants.oauthScopes),
            website: baseUrl)

        // Authorize a user (browser, we will get clientCode).
        let oAuthSwiftCredential = try await client.authenticate(
            app: oAuthApp,
            scope: Scopes(AppConstants.oauthScopes),
            callbackUrlScheme: AppConstants.oauthScheme,
            presentationContextProvider: session)

        // Get authenticated client.
        let authenticatedClient = client.getAuthenticated(token: oAuthSwiftCredential.oauthToken)

        // Get account information from server.
        let account = try await authenticatedClient.verifyCredentials()

        // Get/create account object in database.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()
        let accountData = self.getAccountData(account: account, backgroundContext: backgroundContext)

        accountData.id = account.id
        accountData.username = account.username
        accountData.acct = account.acct
        accountData.displayName = account.displayNameWithoutEmojis
        accountData.note = account.note?.htmlValue
        accountData.url = account.url
        accountData.avatar = account.avatar
        accountData.header = account.header
        accountData.locked = account.locked
        accountData.createdAt = account.createdAt
        accountData.followersCount = Int32(account.followersCount)
        accountData.followingCount = Int32(account.followingCount)
        accountData.statusesCount = Int32(account.statusesCount)

        // Store data about Server and OAuth client.
        accountData.serverUrl = baseUrl
        accountData.clientId = oAuthApp.clientId
        accountData.clientSecret = oAuthApp.clientSecret
        accountData.clientVapidKey = oAuthApp.vapidKey ?? String.empty()

        // Store data about oauth tokens.
        accountData.accessToken = oAuthSwiftCredential.oauthToken
        accountData.refreshToken = oAuthSwiftCredential.oauthRefreshToken

        // Download avatar image.
        if let avatarUrl = account.avatar {
            do {
                let avatarData = try await RemoteFileService.shared.fetchData(url: avatarUrl)
                accountData.avatarData = avatarData
            } catch {
                ErrorService.shared.handle(error, message: "global.error.avatarHasNotBeenDownloaded")
            }
        }

        // Set newly created account as current (only when we create a first account).
        let defaultSettings = ApplicationSettingsHandler.shared.get(viewContext: backgroundContext)
        if defaultSettings.currentAccount == nil {
            defaultSettings.currentAccount = accountData.id
        }

        // Save account/settings data in database.
        CoreDataHandler.shared.save(viewContext: backgroundContext)

        // Return account data.
        let accountModel = accountData.toAccountModel()
        result(accountModel)
    }

    public func refreshAccessTokens() async {
        let accounts = AccountDataHandler.shared.getAccountsData()

        await withTaskGroup(of: Void.self) { group in
            for account in accounts {
                group.addTask {
                    do {
                        _ = try await self.refreshAccessToken(accountData: account)

                        #if DEBUG
                            ToastrService.shared.showSuccess("global.title.newAccessTokenRetrieved", imageSystemName: "key.fill")
                        #endif
                    } catch {
                        #if DEBUG
                            ErrorService.shared.handle(error, message: "global.error.refreshTokenFailed", showToastr: true)
                        #else
                            ErrorService.shared.handle(error, message: "Error during refreshing access token for account '\(account.acct)'.")
                        #endif
                    }
                }
            }
        }
    }

    private func refreshAccessToken(accountData: AccountData) async throws -> AccountModel? {
        let client = PixelfedClient(baseURL: accountData.serverUrl)

        guard let refreshToken = accountData.refreshToken else {
            return nil
        }

        let oAuthSwiftCredential = try await client.refreshToken(clientId: accountData.clientId,
                                                                 clientSecret: accountData.clientSecret,
                                                                 refreshToken: refreshToken)

        // Get authenticated client.
        let authenticatedClient = client.getAuthenticated(token: oAuthSwiftCredential.oauthToken)

        // Get account information from server.
        let account = try await authenticatedClient.verifyCredentials()

        return await self.update(accountId: accountData.id,
                                 basedOn: account,
                                 accessToken: oAuthSwiftCredential.oauthToken,
                                 refreshToken: oAuthSwiftCredential.oauthRefreshToken)
    }

    private func refreshCredentials(for accountModel: AccountModel,
                                    presentationContextProvider: ASWebAuthenticationPresentationContextProviding
    ) async throws -> AccountModel? {

        let client = PixelfedClient(baseURL: accountModel.serverUrl)

        // Create application (we will get clientId and clientSecret).
        let oAuthApp = Application(clientId: accountModel.clientId,
                                   clientSecret: accountModel.clientSecret,
                                   redirectUri: AppConstants.oauthRedirectUri)

        // Authorize a user (browser, we will get clientCode).
        let oAuthSwiftCredential = try await client.authenticate(app: oAuthApp,
                                                                 scope: Scopes(AppConstants.oauthScopes),
                                                                 callbackUrlScheme: AppConstants.oauthScheme,
                                                                 presentationContextProvider: presentationContextProvider)

        // Get authenticated client.
        let authenticatedClient = client.getAuthenticated(token: oAuthSwiftCredential.oauthToken)

        // Get account information from server.
        let account = try await authenticatedClient.verifyCredentials()

        return await self.update(accountId: accountModel.id,
                                 basedOn: account,
                                 accessToken: oAuthSwiftCredential.oauthToken,
                                 refreshToken: oAuthSwiftCredential.oauthRefreshToken)
    }

    private func update(accountId: String,
                        basedOn account: Account,
                        accessToken: String,
                        refreshToken: String?
    ) async -> AccountModel? {
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()
        guard let dbAccount = AccountDataHandler.shared.getAccountData(accountId: accountId, viewContext: backgroundContext) else {
            return nil
        }

        dbAccount.username = account.username
        dbAccount.acct = account.acct
        dbAccount.displayName = account.displayNameWithoutEmojis
        dbAccount.note = account.note?.htmlValue
        dbAccount.url = account.url
        dbAccount.avatar = account.avatar
        dbAccount.header = account.header
        dbAccount.locked = account.locked
        dbAccount.createdAt = account.createdAt
        dbAccount.followersCount = Int32(account.followersCount)
        dbAccount.followingCount = Int32(account.followingCount)
        dbAccount.statusesCount = Int32(account.statusesCount)

        // Store data about new oauth tokens.
        dbAccount.accessToken = accessToken
        dbAccount.refreshToken = refreshToken

        // Download avatar image.
        if let avatarUrl = account.avatar {
            do {
                let avatarData = try await RemoteFileService.shared.fetchData(url: avatarUrl)
                dbAccount.avatarData = avatarData
            } catch {
                ErrorService.shared.handle(error, message: "global.error.avatarHasNotBeenDownloaded")
            }
        }

        // Save account data in database and in application state.
        CoreDataHandler.shared.save(viewContext: backgroundContext)

        return dbAccount.toAccountModel()
    }

    private func getAccountData(account: Account, backgroundContext: NSManagedObjectContext) -> AccountData {
        if let accountFromDb = AccountDataHandler.shared.getAccountData(accountId: account.id, viewContext: backgroundContext) {
            return accountFromDb
        }

        return AccountDataHandler.shared.createAccountDataEntity(viewContext: backgroundContext)
    }
}
