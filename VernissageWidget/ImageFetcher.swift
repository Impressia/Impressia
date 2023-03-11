//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import PixelfedKit

public class ImageFetcher {
    public static let shared = ImageFetcher()
    private init() { }
        
    func fetchWidgetEntries(length: Int = 6) async throws -> [WidgetEntry] {
        let defaultSettings = ApplicationSettingsHandler.shared.getDefaultSettings()
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
        let statuses = try await client.getHomeTimeline(limit: 10)
        var widgetEntries: [WidgetEntry] = []
        
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
            
            let uiImage = await self.getImage(url: imageAttachment.url)
            let uiAvatar = await self.getImage(url: status.account.avatar)

            guard let uiImage, let uiAvatar else {
                continue
            }
            
            let displayDate = Calendar.current.date(byAdding: .minute, value: widgetEntries.count * 10, to: Date())

            widgetEntries.append(WidgetEntry(date: displayDate ?? Date(),
                                             image: uiImage,
                                             avatar: uiAvatar,
                                             displayName: status.account.displayNameWithoutEmojis,
                                             statusId: status.id))
        }
        
        if widgetEntries.isEmpty {
            widgetEntries.append(self.placeholder())
        }
        
        return widgetEntries
    }
    
    func placeholder() -> WidgetEntry {
        WidgetEntry(date: Date(), image: nil, avatar: nil, displayName: "John Misiakiewiczowicz", statusId: "123321")
    }
    
    private func getImage(url: URL?) async -> UIImage? {
        guard let url else {
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if (response as? HTTPURLResponse)?.status?.responseType == .success {
                return UIImage(data: data)?.resized(toWidth: 1200)
            }
            
            return nil
        } catch {
            return nil
        }
    }
}
