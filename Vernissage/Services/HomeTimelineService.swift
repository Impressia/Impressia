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
    
    private let maximumAmountOfDownloadedStatuses = 40
    private let imagePrefetcher = ImagePrefetcher(destination: .diskCache)
    private let semaphore = AsyncSemaphore(value: 1)
    
    public func amountOfNewStatuses(includeReblogs: Bool, hideStatusesWithoutAlt: Bool, modelContext: ModelContext) async -> Int {
        await semaphore.wait()
        defer { semaphore.signal() }
        
        guard let accountData = AccountDataHandler.shared.getCurrentAccountData(modelContext: modelContext) else {
            return 0
        }
        
        guard let accessToken = accountData.accessToken else {
            return 0
        }
                
        // Get maximimum downloaded stauts id.
        guard let lastSeenStatusId = self.getLastLoadedStatusId(accountId: accountData.id, modelContext: modelContext)  else {
            return 0
        }
        
        let client = PixelfedClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        var statuses: [Status] = []
        var latestStatusId: String? = nil
        var breakProcesssing = false;
        
        // There can be more then 40 newest statuses, that's why we have to sometimes send more then one request.
        while true {
            do {
                // Download statuses from the top or the list.
                let downloadedStatuses = try await client.getHomeTimeline(maxId: latestStatusId,
                                                                          limit: self.maximumAmountOfDownloadedStatuses,
                                                                          includeReblogs: includeReblogs)
                
                // Iterate througt the list until we go to already visible status by the user.
                var temporaryList: [Status] = []
                for downloadedStatus in downloadedStatuses.data {
                    guard downloadedStatus.id != lastSeenStatusId else {
                        breakProcesssing = true
                        break
                    }

                    temporaryList.append(downloadedStatus)
                }
                
                // Remove from the list duplicated statuses.
                let visibleStatuses = self.getVisibleStatuses(accountId: accountData.id,
                                                              statuses: temporaryList,
                                                              hideStatusesWithoutAlt: hideStatusesWithoutAlt,
                                                              modelContext: modelContext)
                
                // Add statuses to the list.
                statuses.append(contentsOf: visibleStatuses)
                
                // Break when we go to the already visible status.
                if breakProcesssing {
                    break
                }
                
                // When we discovered more then 100 statuses we can break.
                if statuses.count > 100 {
                    break
                }
                
                // Set status Id which should be used to download next portion of the statuses.
                latestStatusId = downloadedStatuses.getMaxId()
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
            
            // Same rebloged status has been already visible in already processed (visible) portion of data.
            if let reblog = status.reblog, visibleStatuses.contains(where: { $0.reblog?.id == reblog.id || $0.id == reblog.id }) {
                continue
            }
            
            // Same rebloged (orginal) status will be added to visible in same portion of data.
            if let reblog = status.reblog, statusesWithImagesOnly.contains(where: { $0.id == reblog.id }) {
                continue
            }
            
            visibleStatuses.append(status)
        }
        
        return visibleStatuses
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

