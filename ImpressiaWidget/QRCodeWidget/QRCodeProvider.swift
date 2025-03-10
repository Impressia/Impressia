//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI
import Intents

struct QRCodeProvider: TimelineProvider {
    typealias Entry = QRCodeWidgetEntry

    func placeholder(in context: Context) -> QRCodeWidgetEntry {
        AccountFetcher.shared.placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (QRCodeWidgetEntry) -> Void) {
        Task {
            if let widgetEntry = await self.getWidgetEntry().first {
                completion(widgetEntry)
            } else {
                let entry = AccountFetcher.shared.placeholder()
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let currentDate = Date()
            let widgetEntries = await self.getWidgetEntry()

            let nextUpdateDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            let timeline = Timeline(entries: widgetEntries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }

    func getWidgetEntry() async -> [QRCodeWidgetEntry] {
        do {
            return try await AccountFetcher.shared.fetchWidgetEntry()
        } catch {
            return [AccountFetcher.shared.placeholder()]
        }
    }
}
