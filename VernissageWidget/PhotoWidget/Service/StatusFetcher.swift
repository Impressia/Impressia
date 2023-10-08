//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import PixelfedKit

public class StatusFetcher {
    public static let shared = StatusFetcher()
    private init() { }

    func fetchWidgetEntries(length: Int = 8) async throws -> [PhotoWidgetEntry] {
        let defaultSettings = ApplicationSettingsHandler.shared.get()
        guard let accountId = defaultSettings.currentAccount else {
            return [self.placeholder()]
        }

        guard let account = AccountDataHandler.shared.getAccountData(accountId: accountId) else {
            return [self.placeholder()]
        }

        guard let accessToken = account.accessToken else {
            return [self.placeholder()]
        }

        let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(limit: 20, includeReblogs: defaultSettings.showReboostedStatuses)
        var widgetEntries: [PhotoWidgetEntry] = []

        for status in statuses {
            // When we have images for next hour we can skip.
            if widgetEntries.count == length {
                break
            }

            // We have to skip sensitive (we cannot show them on iPhone home screen).
            if status.sensitive {
                continue
            }

            guard let imageAttachment = status.mediaAttachments.first(where: { $0.type == .image }) else {
                continue
            }

            let uiImage = await FileFetcher.shared.getImage(url: imageAttachment.url)
            let uiAvatar = await FileFetcher.shared.getImage(url: status.account.avatar)

            guard let uiImage, let uiAvatar else {
                continue
            }

            let displayDate = Calendar.current.date(byAdding: .minute, value: widgetEntries.count * 20, to: Date())

            widgetEntries.append(PhotoWidgetEntry(date: displayDate ?? Date(),
                                                  image: uiImage,
                                                  avatar: uiAvatar,
                                                  displayName: status.account.displayNameWithoutEmojis,
                                                  statusId: status.id))
        }

        if widgetEntries.isEmpty {
            widgetEntries.append(self.placeholder())
        }

        return widgetEntries.shuffled()
    }

    func placeholder() -> PhotoWidgetEntry {
        PhotoWidgetEntry(date: Date(), image: nil, avatar: nil, displayName: "Caroline Rick", statusId: "")
    }
}
