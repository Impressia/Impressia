//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI
import Intents

struct PhotoProvider: TimelineProvider {
    typealias Entry = PhotoWidgetEntry

    func placeholder(in context: Context) -> PhotoWidgetEntry {
        StatusFetcher.shared.placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (PhotoWidgetEntry) -> Void) {
        Task {
            let widgetEntry = await self.getWidgetEntriesForSnapshot()
            completion(widgetEntry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let currentDate = Date()
            let widgetEntries = await self.getWidgetEntriesForTimeline()

            let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: widgetEntries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    func getWidgetEntriesForSnapshot() async -> PhotoWidgetEntry {
        let entriesFromDatabase = await self.getWidgetEntriesFromDatabase(length: 1)
        if let firstEntry = entriesFromDatabase.first {
            return firstEntry
        }
        
        return StatusFetcher.shared.placeholder()
    }
    
    func getWidgetEntriesForTimeline() async -> [PhotoWidgetEntry] {
        let entriesFromServer = await self.getWidgetEntriesFromServer(length: 3)
        if entriesFromServer.isEmpty == false {
            return entriesFromServer
        }
        
        let entriesFromDatabase = await self.getWidgetEntriesFromDatabase(length: 3)
        if entriesFromDatabase.isEmpty == false {
            return entriesFromDatabase
        }
        
        return [StatusFetcher.shared.placeholder()]
    }

    func getWidgetEntriesFromServer(length: Int) async -> [PhotoWidgetEntry] {
        do {
            return try await StatusFetcher.shared.fetchWidgetEntriesFromServer(length: length)
        } catch {
            return []
        }
    }
    
    func getWidgetEntriesFromDatabase(length: Int) async -> [PhotoWidgetEntry] {
        return await StatusFetcher.shared.fetchWidgetEntriesFromDatabase(length: length)
    }
}
