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

    private let defaultAmountOfDownloadedStatuses = 40
    private let maximumAmountOfDownloadedStatuses = 80
    private let imagePrefetcher = ImagePrefetcher(destination: .diskCache)
    private let semaphore = AsyncSemaphore(value: 1)

    
    public func loadOnBottom(for account: AccountModel, includeReblogs: Bool, hideStatusesWithoutAlt: Bool, modelContext: ModelContext) async throws -> Int {

        // Get minimum downloaded stauts id.
        let oldestStatus = StatusDataHandler.shared.getMinimumStatus(accountId: account.id, modelContext: modelContext)

        guard let oldestStatus = oldestStatus else {
            return 0
        }

        // Load data on bottom of the list.
        let allStatusesFromApi = try await self.load(for: account,
                                                     includeReblogs: includeReblogs,
                                                     hideStatusesWithoutAlt: hideStatusesWithoutAlt,
                                                     modelContext: modelContext,
                                                     maxId: oldestStatus.id)

        // Save data into database.
        try modelContext.save()

        // Start prefetching images.
        self.prefetch(statuses: allStatusesFromApi)

        // Return amount of newly downloaded statuses.
        return allStatusesFromApi.count
    }

    public func refreshTimeline(for account: AccountModel,
                                includeReblogs: Bool,
                                hideStatusesWithoutAlt: Bool,
                                updateLastSeenStatus: Bool = false,
                                modelContext: ModelContext) async throws -> String? {
        await semaphore.wait()
        defer { semaphore.signal() }

        // Retrieve newest visible status (last visible by user).
        let dbNewestStatus = StatusDataHandler.shared.getMaximumStatus(accountId: account.id, modelContext: modelContext)
        let lastSeenStatusId = dbNewestStatus?.id

        // Refresh/load home timeline (refreshing on top downloads always first 40 items).
        // When Apple introduce good way to show new items without scroll to top then we can change that method.
        let allStatusesFromApi = try await self.refresh(for: account,
                                                        includeReblogs: includeReblogs,
                                                        hideStatusesWithoutAlt: hideStatusesWithoutAlt,
                                                        modelContext: modelContext)

        // Update last seen status.
        if let lastSeenStatusId, updateLastSeenStatus == true {
            try self.update(lastSeenStatusId: lastSeenStatusId, for: account, modelContext: modelContext)
        }
        
        // Delete old viewed statuses from database.
        ViewedStatusHandler.shared.deleteOldViewedStatuses(modelContext: modelContext)

        // Start prefetching images.
        self.prefetch(statuses: allStatusesFromApi)

        // Save data into database.
        try modelContext.save()

        // Return id of last seen status.
        return lastSeenStatusId
    }

    public func update(attachment: AttachmentData, withData imageData: Data, imageWidth: Double, imageHeight: Double, modelContext: ModelContext) {
        attachment.data = imageData
        attachment.metaImageWidth = Int32(imageWidth)
        attachment.metaImageHeight = Int32(imageHeight)

        // TODO: Uncomment/remove when exif metadata will be supported.
        // self.setExifProperties(in: attachment, from: imageData)

        // Save data into database.
        try? modelContext.save()
    }

    public func amountOfNewStatuses(for account: AccountModel, includeReblogs: Bool, hideStatusesWithoutAlt: Bool, modelContext: ModelContext) async -> Int {
        await semaphore.wait()
        defer { semaphore.signal() }
        
        guard let accessToken = account.accessToken else {
            return 0
        }

        // Get maximimum downloaded stauts id.
        let newestStatus = StatusDataHandler.shared.getMaximumStatus(accountId: account.id, modelContext: modelContext)
        guard let newestStatus else {
            return 0
        }

        let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
        var statuses: [Status] = []
        var newestStatusId = newestStatus.id

        // There can be more then 80 newest statuses, that's why we have to sometimes send more then one request.
        while true {
            do {
                let downloadedStatuses = try await client.getHomeTimeline(minId: newestStatusId,
                                                                          limit: self.maximumAmountOfDownloadedStatuses,
                                                                          includeReblogs: includeReblogs)

                guard let firstStatus = downloadedStatuses.first else {
                    break
                }

                // We have to include in the counter only statuses with images.
                let statusesWithImagesOnly = downloadedStatuses.getStatusesWithImagesOnly()

                for status in statusesWithImagesOnly {
                    // We have to hide statuses without ALT text.
                    if hideStatusesWithoutAlt && status.statusContainsAltText() == false {
                        continue
                    }

                    // We shouldn't add statuses that are boosted by muted accounts.
                    if AccountRelationshipHandler.shared.isBoostedStatusesMuted(accountId: account.id, status: status, modelContext: modelContext) {
                        continue
                    }

                    // We should add to timeline only statuses that has not been showned to the user already.
                    guard self.hasBeenAlreadyOnTimeline(accountId: account.id, status: status, modelContext: modelContext) == false else {
                        continue
                    }
                    
                    // Same rebloged status has been already visible in current portion of data.
                    if let reblog = status.reblog, statuses.contains(where: { $0.reblog?.id == reblog.id }) {
                        continue
                    }
                    
                    // Same status has been already visible in current portion of data.
                    if let reblog = status.reblog, statusesWithImagesOnly.contains(where: { $0.id == reblog.id }) {
                        continue
                    }
                    
                    statuses.append(status)
                }
                
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

    private func update(lastSeenStatusId: String, for account: AccountModel, modelContext: ModelContext) throws {
        // Save information about last seen status.
        guard let accountDataFromDb = AccountDataHandler.shared.getAccountData(accountId: account.id, modelContext: modelContext) else {
            throw DatabaseError.cannotDownloadAccount
        }

        accountDataFromDb.lastSeenStatusId = lastSeenStatusId
    }
    
    private func update(status statusData: StatusData, basedOn status: Status, for account: AccountModel, modelContext: ModelContext) async throws -> StatusData? {
        // Update status data in database.
        self.copy(from: status, to: statusData, modelContext: modelContext)

        // Save data into database.
        try modelContext.save()

        return statusData
    }
    
    private func refresh(for account: AccountModel, includeReblogs: Bool, hideStatusesWithoutAlt: Bool, modelContext: ModelContext) async throws -> [Status] {
        // Retrieve statuses from API.
        let statuses = try await self.getUniqueStatusesForHomeTimeline(account: account,
                                                                       includeReblogs: includeReblogs,
                                                                       hideStatusesWithoutAlt: hideStatusesWithoutAlt,
                                                                       modelContext: modelContext)

        // Update all existing statuses in database.
        for status in statuses {
            if let dbStatus = StatusDataHandler.shared.getStatusData(accountId: account.id, statusId: status.id, modelContext: modelContext) {
                dbStatus.updateFrom(status)
            }
        }

        // Add statuses which are not existing in database, but has been downloaded via API.
        var statusesToAdd: [Status] = []
        for status in statuses where StatusDataHandler.shared.getStatusData(accountId: account.id,
                                                                            statusId: status.id,
                                                                            modelContext: modelContext) == nil {
            statusesToAdd.append(status)
        }

        // Collection with statuses to remove from database.
        var dbStatusesToRemove: [StatusData] = []
        let allDbStatuses = StatusDataHandler.shared.getAllStatuses(accountId: account.id, modelContext: modelContext)

        // Find statuses to delete (not exiting in the API results).
        for dbStatus in allDbStatuses where !statuses.contains(where: { status in status.id == dbStatus.id }) {
            dbStatusesToRemove.append(dbStatus)
        }

        // Find statuses to delete (duplicates).
        var existingStatusIds: [String] = []
        for dbStatus in allDbStatuses {
            if existingStatusIds.contains(where: { $0 == dbStatus.id }) {
                dbStatusesToRemove.append(dbStatus)
            } else {
                existingStatusIds.append(dbStatus.id)
            }
        }

        // Delete statuses from database.
        if !dbStatusesToRemove.isEmpty {
            for dbStatusToRemove in dbStatusesToRemove {
                modelContext.delete(dbStatusToRemove)
            }
        }

        // Save statuses in database.
        if !statusesToAdd.isEmpty {
            _ = try await self.add(statusesToAdd, for: account, modelContext: modelContext)
        }

        // Return all statuses downloaded from API.
        return statuses
    }

    private func load(for account: AccountModel,
                      includeReblogs: Bool,
                      hideStatusesWithoutAlt: Bool,
                      modelContext: ModelContext,
                      maxId: String? = nil
    ) async throws -> [Status] {
        // Retrieve statuses from API.
        let statuses = try await self.getUniqueStatusesForHomeTimeline(account: account,
                                                                       maxId: maxId,
                                                                       includeReblogs: includeReblogs,
                                                                       hideStatusesWithoutAlt: hideStatusesWithoutAlt,
                                                                       modelContext: modelContext)

        // Save statuses in database.
        try await self.add(statuses, for: account, modelContext: modelContext)

        // Return all statuses downloaded from API.
        return statuses
    }

    private func add(_ statuses: [Status], for account: AccountModel, modelContext: ModelContext) async throws {
        guard let accountDataFromDb = AccountDataHandler.shared.getAccountData(accountId: account.id, modelContext: modelContext) else {
            throw DatabaseError.cannotDownloadAccount
        }

        // Proceed statuses with images only.
        let statusesWithImages = statuses.getStatusesWithImagesOnly()

        // Save all data to database.
        for status in statusesWithImages {
            // Save status to database.
            let statusData = StatusData()
            self.copy(from: status, to: statusData, modelContext: modelContext)

            accountDataFromDb.statuses.append(statusData)
            statusData.pixelfedAccount = accountDataFromDb
            modelContext.insert(statusData)
            
            // Save statusId to viewed statuses.
            let viewedStatus = ViewedStatus(id: status.id, reblogId: status.reblog?.id, date: Date(), pixelfedAccount: accountDataFromDb)
            accountDataFromDb.viewedStatuses.append(viewedStatus)
            modelContext.insert(viewedStatus)
        }
    }

    private func copy(from status: Status, to statusData: StatusData, modelContext: ModelContext) {
        statusData.copyFrom(status)

        for (index, attachment) in status.getAllImageMediaAttachments().enumerated() {

            // Save attachment in database.
            if let attachmentData = statusData.attachments().first(where: { item in item.id == attachment.id }) {
                attachmentData.copyFrom(attachment)
                attachmentData.statusId = statusData.id
                attachmentData.order = Int32(index)
            } else {
                let attachmentData = AttachmentData(id: attachment.id, statusId: statusData.id, url: attachment.url)
                attachmentData.copyFrom(attachment)
                attachmentData.statusId = statusData.id
                attachmentData.order = Int32(index)

                attachmentData.statusRelation = statusData
                statusData.attachmentsRelation.append(attachmentData)
                modelContext.insert(attachmentData)
            }
        }
    }

    private func setExifProperties(in attachmentData: AttachmentData, from imageData: Data) {
        // Read exif information.
        if let exifProperties = imageData.getExifData() {
            if let make = exifProperties.getExifValue("Make"), let model = exifProperties.getExifValue("Model") {
                attachmentData.exifCamera = "\(make) \(model)"
            }

            // "Lens" or "Lens Model"
            if let lens = exifProperties.getExifValue("Lens") {
                attachmentData.exifLens = lens
            }

            if let createData = exifProperties.getExifValue("CreateDate") {
                attachmentData.exifCreatedDate = createData
            }

            if let focalLenIn35mmFilm = exifProperties.getExifValue("FocalLenIn35mmFilm"),
               let fNumber = exifProperties.getExifValue("FNumber")?.calculateExifNumber(),
               let exposureTime = exifProperties.getExifValue("ExposureTime"),
               let photographicSensitivity = exifProperties.getExifValue("PhotographicSensitivity") {
                attachmentData.exifExposure = "\(focalLenIn35mmFilm)mm, f/\(fNumber), \(exposureTime)s, ISO \(photographicSensitivity)"
            }
        }
    }

    private func prefetch(statuses: [Status]) {
        let statusModels = statuses.toStatusModels()
        imagePrefetcher.startPrefetching(with: statusModels.getAllImagesUrls())
    }
    
    private func hasBeenAlreadyOnTimeline(accountId: String, status: Status, modelContext: ModelContext) -> Bool {
        return ViewedStatusHandler.shared.hasBeenAlreadyOnTimeline(accountId: accountId, status: status, modelContext: modelContext)
    }
    
    private func getUniqueStatusesForHomeTimeline(account: AccountModel,
                                                  maxId: EntityId? = nil,
                                                  includeReblogs: Bool? = nil,
                                                  hideStatusesWithoutAlt: Bool = false,
                                                  modelContext: ModelContext) async throws -> [Status] {
            guard let accessToken = account.accessToken else {
                return []
            }
            
            let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
            var lastStatusId = maxId
            var statuses: [Status] = []
            
            while true {
                let downloadedStatuses = try await client.getHomeTimeline(maxId: lastStatusId,
                                                                          limit: self.maximumAmountOfDownloadedStatuses,
                                                                          includeReblogs: includeReblogs)

                // When there is not any older statuses we have to finish.
                guard let lastStatus = downloadedStatuses.last else {
                    break
                }
                
                // We have to include in the counter only statuses with images.
                let statusesWithImagesOnly = downloadedStatuses.getStatusesWithImagesOnly()

                for status in statusesWithImagesOnly {
                    // When we process default amount of statuses to show we can stop adding another ones to the list.
                    if statuses.count == self.defaultAmountOfDownloadedStatuses {
                        break
                    }
                    
                    // We have to hide statuses without ALT text.
                    if hideStatusesWithoutAlt && status.statusContainsAltText() == false {
                        continue
                    }
                    
                    // We shouldn't add statuses that are boosted by muted accounts.
                    if AccountRelationshipHandler.shared.isBoostedStatusesMuted(accountId: account.id, status: status, modelContext: modelContext) {
                        continue
                    }
                    
                    // We should add to timeline only statuses that has not been showned to the user already.
                    guard self.hasBeenAlreadyOnTimeline(accountId: account.id, status: status, modelContext: modelContext) == false else {
                        continue
                    }
                    
                    // Same rebloged status has been already visible in current portion of data.
                    if let reblog = status.reblog, statuses.contains(where: { $0.reblog?.id == reblog.id }) {
                        continue
                    }
                    
                    // Same status has been already visible in current portion of data.
                    if let reblog = status.reblog, statusesWithImagesOnly.contains(where: { $0.id == reblog.id }) {
                        continue
                    }
                    
                    statuses.append(status)
                }
                
                if statuses.count >= self.defaultAmountOfDownloadedStatuses {
                    break
                }
                
                lastStatusId = lastStatus.id
            }

        return statuses
   }
}
