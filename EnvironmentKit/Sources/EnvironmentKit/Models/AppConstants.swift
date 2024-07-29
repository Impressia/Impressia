//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public struct AppConstants {
    // OAuth names have to stay "Vernissage" because of existing users.
    public static let oauthApplicationName = "Vernissage"
    public static let oauthScheme = "oauth-vernissage"
    public static let oauthCallbackPart = "oauth-callback"
    public static let oauthRedirectUri = "\(AppConstants.oauthScheme)://\(oauthCallbackPart)/pixelfed"
    public static let oauthScopes = ["read", "write", "follow", "push"]

    public static let statusScheme = "status-impressia"
    public static let statusCallbackPart = "statuses"
    public static let statusUri = "\(AppConstants.statusScheme)://\(statusCallbackPart)"

    public static let accountScheme = "account-impressia"
    public static let accountCallbackPart = "accounts"
    public static let accountUri = "\(AppConstants.accountScheme)://\(accountCallbackPart)"

    public static let imagePipelineCacheName = "dev.mczachurski.Impressia.DataCache"
    public static let backgroundFetcherName = "dev.mczachurski.Impressia.NotificationFetcher"
    
    // Core data container have to stay "Vernissage" because of existing installations.
    public static let coreDataPersistantContainerName = "Vernissage"
}
