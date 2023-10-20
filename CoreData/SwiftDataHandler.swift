//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import OSLog
import EnvironmentKit
import SwiftData

public class SwiftDataHandler {
    public static let shared = SwiftDataHandler()

    lazy var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AttachmentData.self,
            StatusData.self,
            ApplicationSettings.self,
            AccountData.self,
            ViewedStatus.self,
            AccountRelationship.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
