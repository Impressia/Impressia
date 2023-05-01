//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import PixelfedKit

public class AccountFetcher {
    public static let shared = AccountFetcher()
    private init() { }

    func fetchWidgetEntry() async throws -> [QRCodeWidgetEntry] {
        let defaultSettings = ApplicationSettingsHandler.shared.get()
        guard let accountId = defaultSettings.currentAccount else {
            return [self.placeholder()]
        }

        guard let account = AccountDataHandler.shared.getAccountData(accountId: accountId) else {
            return [self.placeholder()]
        }

        let uiAvatar = await FileFetcher.shared.getImage(url: account.avatar)

        return [
            QRCodeWidgetEntry(date: Date(),
                              accountId: accountId,
                              acct: account.acct,
                              avatar: uiAvatar,
                              displayName: account.displayName,
                              profileUrl: account.url,
                              avatarUrl: account.avatar,
                              portfolioUrl: nil)
        ]
    }

    func placeholder() -> QRCodeWidgetEntry {
        QRCodeWidgetEntry(date: Date(),
                          accountId: "",
                          acct: "@caroline",
                          avatar: nil,
                          displayName: "Caroline Rick",
                          profileUrl: URL(string: "https://pixelfed.org"),
                          avatarUrl: nil,
                          portfolioUrl: nil)
    }
}
