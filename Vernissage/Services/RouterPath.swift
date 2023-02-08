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
    case status(id: String, blurhash: String? = nil, highestImageUrl: URL? = nil, metaImageWidth: Int32? = nil, metaImageHeight: Int32? = nil)
    case statuses(listType: StatusesView.ListType)
    case bookmarks
    case favourites
    case userProfile(accountId: String, accountDisplayName: String?, accountUserName: String)
    case accounts(entityId: String, listType: AccountsView.ListType)
    case signIn
    case thirdParty
}

enum SheetDestinations: Identifiable {
    case newStatusEditor
    case replyToStatusEditor(status: StatusModel)
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
    
    public func handle(url: URL) -> OpenURLAction.Result {
        if url.pathComponents.contains(where: { $0 == "tags" }), let tag = url.pathComponents.last {
            navigate(to: .tag(hashTag: tag))
            return .handled
        } else if url.lastPathComponent.first == "@", let host = url.host {
            let acct = "\(url.lastPathComponent)@\(host)"
            Task {
                await navigateToAccountFrom(acct: acct, url: url)
            }

            return .handled
        }
        
        return urlHandler?(url) ?? .systemAction
    }
    
    public func navigateToAccountFrom(acct: String, url: URL) async {
        Task {
            let results = try? await Client.shared.search?.search(query: acct, resultsType: Mastodon.Search.ResultsType.accounts)
                        
            if let accountFromApi = results?.accounts.first {
                navigate(to: .userProfile(accountId: accountFromApi.id,
                                          accountDisplayName: accountFromApi.displayNameWithoutEmojis,
                                          accountUserName: accountFromApi.acct))
            } else {
                await UIApplication.shared.open(url)
            }
        }
    }
}
