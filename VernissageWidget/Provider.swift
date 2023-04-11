//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    typealias Entry = WidgetEntry

    func placeholder(in context: Context) -> WidgetEntry {
        ImageFetcher.shared.placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        Task {
            if let widgetEntry = await self.getWidgetEntries(length: 1).first {
                completion(widgetEntry)
            } else {
                let entry = ImageFetcher.shared.placeholder()
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let currentDate = Date()
            let widgetEntries = await self.getWidgetEntries()

            let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: widgetEntries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }

    func getWidgetEntries(length: Int = 3) async -> [WidgetEntry] {
        do {
            return try await ImageFetcher.shared.fetchWidgetEntries(length: length)
        } catch {
            return [ImageFetcher.shared.placeholder()]
        }
    }
}
