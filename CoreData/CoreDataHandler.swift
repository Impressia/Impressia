//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import CoreData
import EnvironmentKit

public class CoreDataHandler {
    public static let shared = CoreDataHandler()

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: AppConstants.coreDataPersistantContainerName)
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.mczachurski.vernissage")!
            .appendingPathComponent("Data.sqlite")

        var defaultURL: URL?
        if let storeDescription = container.persistentStoreDescriptions.first, let url = storeDescription.url {
            defaultURL = FileManager.default.fileExists(atPath: url.path) ? url : nil
        }

        if defaultURL == nil {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }

        container.loadPersistentStores(completionHandler: { [unowned container] (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            // Migrate old store do current (shared between app and widget)
            if let url = defaultURL, url.absoluteString != storeURL.absoluteString {
                let coordinator = container.persistentStoreCoordinator
                if let oldStore = coordinator.persistentStore(for: url) {

                    // Migration process.
                    do {
                        try coordinator.migratePersistentStore(oldStore, to: storeURL, options: nil, withType: NSSQLiteStoreType)
                    } catch {
                        print(error.localizedDescription)
                    }

                    // Delete old store.
                    let fileCoordinator = NSFileCoordinator(filePresenter: nil)
                    fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor: { url in
                        do {
                            try FileManager.default.removeItem(at: url)
                        } catch {
                            print(error.localizedDescription)
                        }
                    })
                }
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    public func newBackgroundContext() -> NSManagedObjectContext {
        self.container.newBackgroundContext()
    }

    public func save(viewContext: NSManagedObjectContext? = nil) {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        if context.hasChanges {
            context.performAndWait {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate.
                    // You should not use this function in a shipping application, although it may be useful during development.

                    #if DEBUG
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    #else
                    CoreDataError.shared.handle(error, message: "An error occurred while writing the data.")
                    #endif
                }
            }
        }
    }
}
