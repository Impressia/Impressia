//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData
import PixelfedKit

class StatusDataHandler {
    public static let shared = StatusDataHandler()
    private init() { }

    func getAllStatuses(accountId: String) -> [StatusData] {
        let context = CoreDataHandler.shared.container.viewContext
        let fetchRequest = StatusData.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pixelfedAccount.id = %@", accountId)

        do {
            return try context.fetch(fetchRequest)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching status (getStatusData).")
            return []
        }
    }

    func getStatusData(accountId: String, statusId: String, viewContext: NSManagedObjectContext? = nil) -> StatusData? {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = StatusData.fetchRequest()

        fetchRequest.fetchLimit = 1
        let predicate1 = NSPredicate(format: "id = %@", statusId)
        let predicate2 = NSPredicate(format: "pixelfedAccount.id = %@", accountId)

        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching status (getStatusData).")
            return nil
        }
    }

    func getMaximumStatus(accountId: String, viewContext: NSManagedObjectContext? = nil) -> StatusData? {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = StatusData.fetchRequest()

        fetchRequest.fetchLimit = 1

        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pixelfedAccount.id = %@", accountId)

        do {
            let statuses = try context.fetch(fetchRequest)
            return statuses.first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching maximum status (getMaximumStatus).")
            return nil
        }
    }

    func getMinimumStatus(accountId: String, viewContext: NSManagedObjectContext? = nil) -> StatusData? {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = StatusData.fetchRequest()

        fetchRequest.fetchLimit = 1

        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pixelfedAccount.id = %@", accountId)

        do {
            let statuses = try context.fetch(fetchRequest)
            return statuses.first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching minimum status (getMinimumtatus).")
            return nil
        }
    }

    func remove(accountId: String, statusId: String) {
        let status = self.getStatusData(accountId: accountId, statusId: statusId)
        guard let status else {
            return
        }

        let context = CoreDataHandler.shared.container.viewContext
        context.delete(status)

        do {
            try context.save()
        } catch {
            CoreDataError.shared.handle(error, message: "Error during deleting status (remove).")
        }
    }

    func remove(accountId: String, statuses: [StatusData]) {
        let context = CoreDataHandler.shared.container.viewContext

        for status in statuses {
            context.delete(status)
        }

        do {
            try context.save()
        } catch {
            CoreDataError.shared.handle(error, message: "Error during deleting status (remove).")
        }
    }

    func setFavourited(accountId: String, statusId: String) {
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        if let statusData = self.getStatusData(accountId: accountId, statusId: statusId, viewContext: backgroundContext) {
            statusData.favourited = true
            CoreDataHandler.shared.save(viewContext: backgroundContext)
        }
    }

    func createStatusDataEntity(viewContext: NSManagedObjectContext? = nil) -> StatusData {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        return StatusData(context: context)
    }
}
