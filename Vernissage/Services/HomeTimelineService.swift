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

/// Service responsible for managing home timeline.
@MainActor
public class HomeTimelineService {
    public static let shared = HomeTimelineService()
    private init() { }
    
    private let maximumAmountOfDownloadedStatuses = 80
    private let imagePrefetcher = ImagePrefetcher(destination: .diskCache)
    private let semaphore = AsyncSemaphore(value: 1)
    
    public func amountOfNewStatuses(for account: AccountModel, includeReblogs: Bool, hideStatusesWithoutAlt: Bool, modelContext: ModelContext) async -> Int {
        await semaphore.wait()
        defer { semaphore.signal() }
        
        guard let accessToken = account.accessToken else {
            return 0
        }
                
        // Get maximimum downloaded stauts id.
        guard let lastSeenStatusId = self.getLastLoadedStatusId(accountId: account.id, modelContext: modelContext)  else {
            return 0
        }
        
        let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
        var statuses: [Status] = []
        var newestStatusId = lastSeenStatusId
        
        // There can be more then 80 newest statuses, that's why we have to sometimes send more then one request.
        while true {
            do {
                let downloadedStatuses = try await client.getHomeTimeline(minId: newestStatusId,
                                                                          limit: self.maximumAmountOfDownloadedStatuses,
                                                                          includeReblogs: includeReblogs)
                
                guard let firstStatus = downloadedStatuses.first else {
                    break
                }
                                
                let visibleStatuses = self.getVisibleStatuses(accountId: account.id,
                                                              statuses: downloadedStatuses,
                                                              hideStatusesWithoutAlt: hideStatusesWithoutAlt,
                                                              modelContext: modelContext)

                statuses.append(contentsOf: visibleStatuses)
                
                newestStatusId = firstStatus.id
            } catch {
                ErrorService.shared.handle(error, message: "global.error.errorDuringDownloadingNewStatuses")
                break
            }
        }
        
        // Start prefetching images.
        self.prefetch(statuses: statuses)
        
        // Return number of new statuses not visible yet on the timeline.
        return statuses.count
    }
    
    public func getVisibleStatuses(accountId: String, statuses: [Status], hideStatusesWithoutAlt: Bool, modelContext: ModelContext) -> [Status] {
        // We have to include in the counter only statuses with images.
        let statusesWithImagesOnly = statuses.getStatusesWithImagesOnly()
        var visibleStatuses: [Status] = []
        
        for status in statusesWithImagesOnly {
            
            // We have to hide statuses without ALT text.
            if hideStatusesWithoutAlt && status.statusContainsAltText() == false {
                continue
            }
            
            // We shouldn't add statuses that are boosted by muted accounts.
            if AccountRelationshipHandler.shared.isBoostedStatusesMuted(accountId: accountId, status: status, modelContext: modelContext) {
                continue
            }
            
            // We should add to timeline only statuses that has not been showned to the user already.
            guard self.hasBeenAlreadyOnTimeline(accountId: accountId, status: status, modelContext: modelContext) == false else {
                continue
            }
            
            // Same rebloged status has been already visible in current portion of data.
            if let reblog = status.reblog, visibleStatuses.contains(where: { $0.reblog?.id == reblog.id || $0.id == reblog.id }) {
                continue
            }
            
            visibleStatuses.append(status)
        }
        
        return visibleStatuses
    }
    
    public func update(lastSeenStatusId: String?, lastLoadedStatusId: String?, applicationState: ApplicationState, modelContext: ModelContext) throws {
        guard let accountId = applicationState.account?.id else {
            return
        }
        
        try AccountDataHandler.shared.update(lastSeenStatusId: lastSeenStatusId,
                                             lastLoadedStatusId: lastLoadedStatusId,
                                             accountId: accountId,
                                             modelContext: modelContext)
        
        if (applicationState.lastSeenStatusId ?? "0") < (lastSeenStatusId ?? "0") {
            applicationState.lastSeenStatusId = lastSeenStatusId
        }
    }
    
    private func hasBeenAlreadyOnTimeline(accountId: String, status: Status, modelContext: ModelContext) -> Bool {
         return ViewedStatusHandler.shared.hasBeenAlreadyOnTimeline(accountId: accountId, status: status, modelContext: modelContext)
     }
    
    private func getLastLoadedStatusId(accountId: String, modelContext: ModelContext) -> String? {
        let accountData = AccountDataHandler.shared.getAccountData(accountId: accountId, modelContext: modelContext)
        return accountData?.lastLoadedStatusId
    }
    
    private func prefetch(statuses: [Status]) {
        let statusModels = statuses.toStatusModels()
        imagePrefetcher.startPrefetching(with: statusModels.getAllImagesUrls())
    }
    
}

