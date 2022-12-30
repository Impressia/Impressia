//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

@main
struct VernissageApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(ApplicationState.shared)
            }
            .navigationViewStyle(.stack)
        }
    }
}
