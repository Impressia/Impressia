//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import CoreData

public class CoreDataHandler {
    public static let shared = CoreDataHandler()

    public let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Vernissage")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

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
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        self.container.newBackgroundContext()
    }
    
    public func save() {
        let context = self.container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful during development.

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataHandler {
    public static var memory: CoreDataHandler = {
        CoreDataHandler(inMemory: true)
    }()
}

extension CoreDataHandler {
    public static var preview: CoreDataHandler = {
        let result = CoreDataHandler(inMemory: true)
        let viewContext = result.container.viewContext
        
        let statusData = StatusData(context: viewContext)
        statusData.id = "516272295308651148"
        statusData.uri = "https://pixelfed.social/p/z428/516272295308651148"
        statusData.url = URL(string: "https://pixelfed.social/p/z428/516272295308651148")
        statusData.content = "4: Along the way.<br />\n<a href=\"https://pixelfed.social/discover/tags/outerworld?src=hash\" title=\"#outerworld\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#outerworld</a> <a href=\"https://pixelfed.social/discover/tags/pixelfed365?src=hash\" title=\"#pixelfed365\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#pixelfed365</a> <a href=\"https://pixelfed.social/discover/tags/dresden?src=hash\" title=\"#dresden\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#dresden</a> <a href=\"https://pixelfed.social/discover/tags/photography?src=hash\" title=\"#photography\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#photography</a> <a href=\"https://pixelfed.social/discover/tags/smartphonephotography?src=hash\" title=\"#smartphonephotography\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#smartphonephotography</a> <a href=\"https://pixelfed.social/discover/tags/afternoons?src=hash\" title=\"#afternoons\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#afternoons</a> <a href=\"https://pixelfed.social/discover/tags/grey?src=hash\" title=\"#grey\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#grey</a>"
        statusData.reblogsCount = 12
        statusData.createdAt = "2023-01-04T15:21:47.000Z"
        statusData.visibility = "public"
        statusData.applicationName = "web"
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}

public struct PreviewData {
    static func getStatus() -> StatusData {
        let statusData = StatusData()
        statusData.id = "516272295308651148"
        statusData.uri = "https://pixelfed.social/p/z428/516272295308651148"
        statusData.url = URL(string: "https://pixelfed.social/p/z428/516272295308651148")
        statusData.content = "4: Along the way.<br />\n<a href=\"https://pixelfed.social/discover/tags/outerworld?src=hash\" title=\"#outerworld\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#outerworld</a> <a href=\"https://pixelfed.social/discover/tags/pixelfed365?src=hash\" title=\"#pixelfed365\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#pixelfed365</a> <a href=\"https://pixelfed.social/discover/tags/dresden?src=hash\" title=\"#dresden\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#dresden</a> <a href=\"https://pixelfed.social/discover/tags/photography?src=hash\" title=\"#photography\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#photography</a> <a href=\"https://pixelfed.social/discover/tags/smartphonephotography?src=hash\" title=\"#smartphonephotography\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#smartphonephotography</a> <a href=\"https://pixelfed.social/discover/tags/afternoons?src=hash\" title=\"#afternoons\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#afternoons</a> <a href=\"https://pixelfed.social/discover/tags/grey?src=hash\" title=\"#grey\" class=\"u-url hashtag\" rel=\"external nofollow noopener\">#grey</a>"
        statusData.reblogsCount = 12
        statusData.createdAt = "2023-01-04T15:21:47.000Z"
        statusData.visibility = "public"
        statusData.applicationName = "web"
        
        return statusData
    }
}

