//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import PixelfedKit

class StatusDataHandler {
    public static let shared = StatusDataHandler()
    private init() { }

    func getAllStatuses(accountId: String, modelContext: ModelContext) -> [StatusData] {
        do {
            var fetchDescriptor = FetchDescriptor<StatusData>(predicate: #Predicate { statusData in
                statusData.pixelfedAccount?.id == accountId
            }, sortBy: [SortDescriptor(\.id, order: .reverse)])
            fetchDescriptor.includePendingChanges = true

            return try modelContext.fetch(fetchDescriptor)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching status (getStatusData).")
            return []
        }
    }

    func getAllOlderStatuses(accountId: String, statusId: String, modelContext: ModelContext) -> [StatusData] {
        do {
            var fetchDescriptor = FetchDescriptor<StatusData>(predicate: #Predicate { statusData in
                statusData.pixelfedAccount?.id == accountId && statusData.id < statusId
            }, sortBy: [SortDescriptor(\.id, order: .reverse)])
            fetchDescriptor.includePendingChanges = true

            return try modelContext.fetch(fetchDescriptor)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching status (getStatusData).")
            return []
        }
    }

    func getStatusData(accountId: String, statusId: String, modelContext: ModelContext) -> StatusData? {
        do {
            var fetchDescriptor = FetchDescriptor<StatusData>(predicate: #Predicate { statusData in
                statusData.pixelfedAccount?.id == accountId && statusData.id == statusId
            })
            fetchDescriptor.fetchLimit = 1
            fetchDescriptor.includePendingChanges = true
            
            return try modelContext.fetch(fetchDescriptor).first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching status (getStatusData).")
            return nil
        }
    }

    func getMaximumStatus(accountId: String, modelContext: ModelContext) -> StatusData? {
        do {
            var fetchDescriptor = FetchDescriptor<StatusData>(predicate: #Predicate { statusData in
                statusData.pixelfedAccount?.id == accountId
            }, sortBy: [SortDescriptor(\.id, order: .reverse)])
            fetchDescriptor.fetchLimit = 1
            fetchDescriptor.includePendingChanges = true
            
            let statuses = try modelContext.fetch(fetchDescriptor)
            return statuses.first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching maximum status (getMaximumStatus).")
            return nil
        }
    }

    func getMinimumStatus(accountId: String, modelContext: ModelContext) -> StatusData? {
        do {
            var fetchDescriptor = FetchDescriptor<StatusData>(predicate: #Predicate { statusData in
                statusData.pixelfedAccount?.id == accountId
            }, sortBy: [SortDescriptor(\.id, order: .forward)])
            fetchDescriptor.fetchLimit = 1
            fetchDescriptor.includePendingChanges = true
            
            let statuses = try modelContext.fetch(fetchDescriptor)
            return statuses.first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching minimum status (getMinimumtatus).")
            return nil
        }
    }

    func remove(accountId: String, statusId: String, modelContext: ModelContext) {
        let status = self.getStatusData(accountId: accountId, statusId: statusId, modelContext: modelContext)
        guard let status else {
            return
        }

        do {
            modelContext.delete(status)
            try modelContext.save()
        } catch {
            CoreDataError.shared.handle(error, message: "Error during deleting status (remove).")
        }
    }

    func setFavourited(accountId: String, statusId: String, modelContext: ModelContext) {
        if let statusData = self.getStatusData(accountId: accountId, statusId: statusId, modelContext: modelContext) {
            statusData.favourited = true

            do {
                try modelContext.save()
            } catch {
                CoreDataError.shared.handle(error, message: "Error during deleting status (setFavourited).")
            }
        }
    }
}
