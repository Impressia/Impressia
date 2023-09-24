//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData
import PixelfedKit
import ClientKit
import ServicesKit
import Nuke

/// Service responsible for managing home timeline.
public class HomeTimelineService {
    public static let shared = HomeTimelineService()
    private init() { }

    private let defaultAmountOfDownloadedStatuses = 40
    private let imagePrefetcher = ImagePrefetcher(destination: .diskCache)

    @MainActor
    public func loadOnBottom(for account: AccountModel) async throws -> Int {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get minimum downloaded stauts id.
        let oldestStatus = StatusDataHandler.shared.getMinimumStatus(accountId: account.id, viewContext: backgroundContext)

        guard let oldestStatus = oldestStatus else {
            return 0
        }

        // Load data on bottom of the list.
        let allStatusesFromApi = try await self.load(for: account, on: backgroundContext, maxId: oldestStatus.id)

        // Save data into database.
        CoreDataHandler.shared.save(viewContext: backgroundContext)

        // Start prefetching images.
        self.prefetch(statuses: allStatusesFromApi)

        // Return amount of newly downloaded statuses.
        return allStatusesFromApi.count
    }

    @MainActor
    public func refreshTimeline(for account: AccountModel, updateLastSeenStatus: Bool = false) async throws -> String? {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Retrieve newest visible status (last visible by user).
        let dbNewestStatus = StatusDataHandler.shared.getMaximumStatus(accountId: account.id, viewContext: backgroundContext)
        let lastSeenStatusId = dbNewestStatus?.rebloggedStatusId ?? dbNewestStatus?.id

        // Refresh/load home timeline (refreshing on top downloads always first 40 items).
        // When Apple introduce good way to show new items without scroll to top then we can change that method.
        let allStatusesFromApi = try await self.refresh(for: account, on: backgroundContext)

        // Update last seen status.
        if let lastSeenStatusId, updateLastSeenStatus == true {
            try self.update(lastSeenStatusId: lastSeenStatusId, for: account, on: backgroundContext)
        }
        
        // Start prefetching images.
        self.prefetch(statuses: allStatusesFromApi)
        
        // Save data into database.
        CoreDataHandler.shared.save(viewContext: backgroundContext)

        // Return id of last seen status.
        return lastSeenStatusId
    }

    private func update(lastSeenStatusId: String, for account: AccountModel, on backgroundContext: NSManagedObjectContext) throws {
        // Save information about last seen status.
        guard let accountDataFromDb = AccountDataHandler.shared.getAccountData(accountId: account.id, viewContext: backgroundContext) else {
            throw DatabaseError.cannotDownloadAccount
        }

        accountDataFromDb.lastSeenStatusId = lastSeenStatusId
    }

    public func update(status statusData: StatusData, basedOn status: Status, for account: AccountModel) async throws -> StatusData? {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Update status data in database.
        self.copy(from: status, to: statusData, on: backgroundContext)

        // Save data into database.
        CoreDataHandler.shared.save(viewContext: backgroundContext)

        return statusData
    }

    @MainActor
    public func update(attachment: AttachmentData, withData imageData: Data, imageWidth: Double, imageHeight: Double) {
        attachment.data = imageData
        attachment.metaImageWidth = Int32(imageWidth)
        attachment.metaImageHeight = Int32(imageHeight)

        // TODO: Uncomment/remove when exif metadata will be supported.
        // self.setExifProperties(in: attachment, from: imageData)

        // Save data into database.
        CoreDataHandler.shared.save()
    }

    public func amountOfNewStatuses(for account: AccountModel) async -> Int {
        guard let accessToken = account.accessToken else {
            return 0
        }

        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get maximimum downloaded stauts id.
        let newestStatus = StatusDataHandler.shared.getMaximumStatus(accountId: account.id, viewContext: backgroundContext)
        guard let newestStatus else {
            return 0
        }

        let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
        var amountOfStatuses = 0
        var newestStatusId = newestStatus.id

        // There can be more then 40 newest statuses, that's why we have to sometimes send more then one request.
        while true {
            do {
                let downloadedStatuses = try await client.getHomeTimeline(minId: newestStatusId, limit: self.defaultAmountOfDownloadedStatuses)
                guard let firstStatus = downloadedStatuses.first else {
                    break
                }

                // We have to include in the counter only statuses with images.
                let statusesWithImagesOnly = downloadedStatuses.getStatusesWithImagesOnly()

                amountOfStatuses = amountOfStatuses + statusesWithImagesOnly.count
                newestStatusId = firstStatus.id
            } catch {
                ErrorService.shared.handle(error, message: "Error during downloading new statuses for amount of new statuses.")
                break
            }
        }

        return amountOfStatuses
    }

    private func refresh(for account: AccountModel, on backgroundContext: NSManagedObjectContext) async throws -> [Status] {
        guard let accessToken = account.accessToken else {
            return []
        }

        // Retrieve statuses from API.
        let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(limit: self.defaultAmountOfDownloadedStatuses)

        // Update all existing statuses in database.
        for status in statuses {
            if let dbStatus = StatusDataHandler.shared.getStatusData(accountId: account.id, statusId: status.id, viewContext: backgroundContext) {
                dbStatus.updateFrom(status)
            }
        }

        // Add statuses which are not existing in database, but has been downloaded via API.
        var statusesToAdd: [Status] = []
        for status in statuses where StatusDataHandler.shared.getStatusData(accountId: account.id,
                                                                            statusId: status.id,
                                                                            viewContext: backgroundContext) == nil {
            statusesToAdd.append(status)
        }

        // Collection with statuses to remove from database.
        var dbStatusesToRemove: [StatusData] = []
        let allDbStatuses = StatusDataHandler.shared.getAllStatuses(accountId: account.id, viewContext: backgroundContext)

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
                backgroundContext.delete(dbStatusToRemove)
            }
        }

        // Save statuses in database.
        if !statusesToAdd.isEmpty {
            _ = try await self.add(statusesToAdd, for: account, on: backgroundContext)
        }

        // Return all statuses downloaded from API.
        return statuses
    }

    private func load(for account: AccountModel,
                      on backgroundContext: NSManagedObjectContext,
                      minId: String? = nil,
                      maxId: String? = nil
    ) async throws -> [Status] {
        guard let accessToken = account.accessToken else {
            return []
        }

        // Retrieve statuses from API.
        let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(maxId: maxId, minId: minId, limit: self.defaultAmountOfDownloadedStatuses)

        // Save statuses in database.
        try await self.add(statuses, for: account, on: backgroundContext)

        // Return all statuses downloaded from API.
        return statuses
    }

    private func add(_ statuses: [Status],
                     for account: AccountModel,
                     on backgroundContext: NSManagedObjectContext
    ) async throws {

        guard let accountDataFromDb = AccountDataHandler.shared.getAccountData(accountId: account.id, viewContext: backgroundContext) else {
            throw DatabaseError.cannotDownloadAccount
        }

        // Proceed statuses with images only.
        let statusesWithImages = statuses.getStatusesWithImagesOnly()

        // Save status data in database.
        for status in statusesWithImages {
            let statusData = StatusDataHandler.shared.createStatusDataEntity(viewContext: backgroundContext)

            statusData.pixelfedAccount = accountDataFromDb
            accountDataFromDb.addToStatuses(statusData)

            self.copy(from: status, to: statusData, on: backgroundContext)
        }
    }

    private func copy(from status: Status,
                      to statusData: StatusData,
                      on backgroundContext: NSManagedObjectContext
    ) {
        statusData.copyFrom(status)

        for (index, attachment) in status.getAllImageMediaAttachments().enumerated() {

            // Save attachment in database.
            let attachmentData = statusData.attachments().first { item in item.id == attachment.id }
                ?? AttachmentDataHandler.shared.createAttachmnentDataEntity(viewContext: backgroundContext)

            attachmentData.copyFrom(attachment)
            attachmentData.statusId = statusData.id
            attachmentData.order = Int32(index)

            if attachmentData.isInserted {
                attachmentData.statusRelation = statusData
                statusData.addToAttachmentsRelation(attachmentData)
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
        let statusModels = statuses.getStatusesWithImagesOnly().toStatusModels()
        imagePrefetcher.startPrefetching(with: statusModels.getAllImagesUrls())
    }
}
