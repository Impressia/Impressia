//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import PixelfedKit
import ClientKit
import ServicesKit
import Nuke
import OSLog
import EnvironmentKit
import Semaphore

/// Service responsible for managing notifications.
@MainActor
public class NotificationsService {
    public static let shared = NotificationsService()
    private init() { }
    
    private let semaphore = AsyncSemaphore(value: 1)
    
    public func newNotificationsHasBeenAdded(for account: AccountModel, modelContext: ModelContext) async -> Bool {
        await semaphore.wait()
        defer { semaphore.signal() }
        
        guard let accessToken = account.accessToken else {
            return false
        }
     
        // Get maximimum downloaded stauts id.
        guard let lastSeenNotificationId = self.getLastSeenNotificationId(accountId: account.id, modelContext: modelContext)  else {
            return false
        }
        
        let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
        
        do {
            let linkableNotifications = try await client.notifications(minId: lastSeenNotificationId, limit: 5)
            return linkableNotifications.data.first(where: { $0.id != lastSeenNotificationId }) != nil
        } catch {
            ErrorService.shared.handle(error, message: "notifications.error.loadingNotificationsFailed")
            return false
        }
    }
    
    private func getLastSeenNotificationId(accountId: String, modelContext: ModelContext) -> String? {
        let accountData = AccountDataHandler.shared.getAccountData(accountId: accountId, modelContext: modelContext)
        return accountData?.lastSeenNotificationId
    }
}
