//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import PixelfedKit

class ViewedStatusHandler {
    public static let shared = ViewedStatusHandler()
    private init() { }
    
    /// Check if given status (real picture) has been already visible on the timeline (during last month).
    func hasBeenAlreadyOnTimeline(accountId: String, status: Status, modelContext: ModelContext) -> Bool {
        guard let reblog = status.reblog else {
            return false
        }

        do {
            let reblogId = reblog.id
            var fetchDescriptor = FetchDescriptor<ViewedStatus>(predicate: #Predicate { viewedStatus in
                (viewedStatus.id == reblogId || viewedStatus.reblogId == reblogId) && viewedStatus.pixelfedAccount?.id == accountId
            })
            fetchDescriptor.fetchLimit = 1
            fetchDescriptor.includePendingChanges = true
            
            guard let first = try modelContext.fetch(fetchDescriptor).first else {
                return false
            }
            
            if first.reblogId == nil {
                return true
            }
            
            if first.id != status.id {
                return true
            }
            
            return false
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching viewed statuses (hasBeenAlreadyOnTimeline).")
            return false
        }
    }
    
    /// Mark to delete statuses older then one month.
    func deleteOldViewedStatuses(modelContext: ModelContext) {
        let oldViewedStatuses = self.getOldViewedStatuses(modelContext: modelContext)
        for status in oldViewedStatuses {
            modelContext.delete(status)
        }
    }
    
    private func getOldViewedStatuses(modelContext: ModelContext) -> [ViewedStatus] {
        guard let date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
            return []
        }
        
        do {
            var fetchDescriptor = FetchDescriptor<ViewedStatus>(predicate: #Predicate { viewedStatus in
                viewedStatus.date < date
            })
            fetchDescriptor.includePendingChanges = true
            
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching viewed statuses (getOldViewedStatuses).")
            return []
        }
    }
}
