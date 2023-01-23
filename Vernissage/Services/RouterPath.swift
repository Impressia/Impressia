//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import Foundation
import MastodonKit

enum RouteurDestinations: Hashable {
    case tag(hashTag: String)
    case status(id: String, blurhash: String? = nil, metaImageWidth: Int32? = nil, metaImageHeight: Int32? = nil)
    case statuses(listType: StatusesView.ListType)
    case userProfile(accountId: String, accountDisplayName: String?, accountUserName: String)
    case accounts(entityId: String, listType: AccountsView.ListType)
    case signIn
}

enum SheetDestinations: Identifiable {
    case newStatusEditor
    case replyToStatusEditor(status: StatusViewModel)
    case settings
  
    public var id: String {
        switch self {
        case .replyToStatusEditor, .newStatusEditor:
            return "statusEditor"
        case .settings:
            return "settings"
        }
    }
}

@MainActor
class RouterPath: ObservableObject {
    public var urlHandler: ((URL) -> OpenURLAction.Result)?
  
    @Published public var path: [RouteurDestinations] = []
    @Published public var presentedSheet: SheetDestinations?

    public init() {}

    public func navigate(to: RouteurDestinations) {
        path.append(to)
    }
    
    public func handle(url: URL, accountData: AccountData? = nil) -> OpenURLAction.Result {
        if url.pathComponents.contains(where: { $0 == "tags" }), let tag = url.pathComponents.last {
            navigate(to: .tag(hashTag: tag))
            return .handled
        } else if url.lastPathComponent.first == "@", let host = url.host {
            let acct = "\(url.lastPathComponent)@\(host)"
            Task {
                await navigateToAccountFrom(acct: acct, url: url, accountData: accountData)
            }

            return .handled
        }
        
        return urlHandler?(url) ?? .systemAction
    }
    
    public func navigateToAccountFrom(acct: String, url: URL, accountData: AccountData? = nil) async {
        guard let accountData else { return }
        
        Task {
            let results = try? await SearchService.shared.search(accountData: accountData,
                                                                 query: acct,
                                                                 resultsType: Mastodon.Search.ResultsType.accounts)
                        
            if let account = results?.accounts.first {
                navigate(to: .userProfile(accountId: account.id, accountDisplayName: account.displayNameWithoutEmojis, accountUserName: account.acct))
            } else {
                await UIApplication.shared.open(url)
            }
        }
    }
}
