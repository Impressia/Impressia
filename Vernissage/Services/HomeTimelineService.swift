//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData
import PixelfedKit

/// Service responsible for managing home timeline.
public class HomeTimelineService {
    public static let shared = HomeTimelineService()
    private init() { }

    public func loadOnBottom(for account: AccountModel) async throws -> Int {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get minimum downloaded stauts id.
        let oldestStatus = StatusDataHandler.shared.getMinimumStatus(accountId: account.id, viewContext: backgroundContext)

        guard let oldestStatus = oldestStatus else {
            return 0
        }

        // Load data on bottom of the list.
        let newStatuses = try await self.load(for: account, on: backgroundContext, maxId: oldestStatus.id)

        // Save data into database.
        CoreDataHandler.shared.save(viewContext: backgroundContext)

        // Return amount of newly downloaded statuses.
        return newStatuses.count
    }

    public func loadOnTop(for account: AccountModel) async throws -> String? {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Refresh/load home timeline (refreshing on top downloads always first 40 items).
        // When Apple introduce good way to show new items without scroll to top then we can change that method.
        let lastSeenStatusId = try await self.refresh(for: account, on: backgroundContext)

        // Save data into database.
        CoreDataHandler.shared.save(viewContext: backgroundContext)

        // Return id of last seen status.
        return lastSeenStatusId
    }

    public func save(lastSeenStatusId: String, for account: AccountModel) async throws {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Save information about last seen status.
        guard let accountDataFromDb = AccountDataHandler.shared.getAccountData(accountId: account.id, viewContext: backgroundContext) else {
            throw DatabaseError.cannotDownloadAccount
        }

        accountDataFromDb.lastSeenStatusId = lastSeenStatusId

        // Save data into database.
        CoreDataHandler.shared.save(viewContext: backgroundContext)
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
        self.setExifProperties(in: attachment, from: imageData)

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
                let downloadedStatuses = try await client.getHomeTimeline(minId: newestStatusId, limit: 40)
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

    private func refresh(for account: AccountModel, on backgroundContext: NSManagedObjectContext) async throws -> String? {
        guard let accessToken = account.accessToken else {
            return nil
        }

        // Retrieve statuses from API.
        let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(limit: 40)

        // Retrieve all statuses from database.
        let dbStatuses = StatusDataHandler.shared.getAllStatuses(accountId: account.id)
        let lastSeenStatusId = dbStatuses.last?.rebloggedStatusId ?? dbStatuses.last?.id

        // Remove statuses that are not in 40 downloaded once.
        var dbStatusesToRemove: [StatusData] = []
        for dbStatus in dbStatuses where !statuses.contains(where: { status in status.id == dbStatus.id }) {
            dbStatusesToRemove.append(dbStatus)
        }

        if !dbStatusesToRemove.isEmpty {
            StatusDataHandler.shared.remove(accountId: account.id, statuses: dbStatusesToRemove)
        }

        // Add statuses which are not existing in database, but has been downloaded via API.
        var statusesToAdd: [Status] = []
        for status in statuses where !dbStatuses.contains(where: { statusData in statusData.id == status.id }) {
            statusesToAdd.append(status)
        }

        // Save statuses in database.
        if !statusesToAdd.isEmpty {
            _ = try await self.save(statuses: statusesToAdd, for: account, on: backgroundContext)
        }

        return lastSeenStatusId
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
        let statuses = try await client.getHomeTimeline(maxId: maxId, minId: minId, limit: 20)

        // Save statuses in database.
        return try await self.save(statuses: statuses, for: account, on: backgroundContext)
    }

    private func save(statuses: [Status],
                      for account: AccountModel,
                      on backgroundContext: NSManagedObjectContext
    ) async throws -> [Status] {

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

        return statusesWithImages
    }

    private func copy(from status: Status,
                      to statusData: StatusData,
                      on backgroundContext: NSManagedObjectContext
    ) {
        statusData.copyFrom(status)

        for attachment in status.getAllImageMediaAttachments() {

            // Save attachment in database.
            let attachmentData = statusData.attachments().first { item in item.id == attachment.id }
                ?? AttachmentDataHandler.shared.createAttachmnentDataEntity(viewContext: backgroundContext)

            attachmentData.copyFrom(attachment)
            attachmentData.statusId = statusData.id

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
}
