//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Foundation
import PixelfedKit
import ClientKit
import WidgetsKit

enum RouteurDestinations: Hashable {
    case tag(hashTag: String)
    case status(id: String, blurhash: String? = nil, highestImageUrl: URL? = nil, metaImageWidth: Int32? = nil, metaImageHeight: Int32? = nil)
    case statuses(listType: StatusesView.ListType)
    case bookmarks
    case favourites
    case userProfile(accountId: String, accountDisplayName: String?, accountUserName: String)
    case accounts(listType: AccountsView.ListType)
    case signIn
    case thirdParty
    case photoEditor(photoAttachment: PhotoAttachment)
    case hashtags(listType: HashtagsView.ListType)
    case accountsPhoto(listType: AccountsPhotoView.ListType)
    case search
    case editProfile
    case instance
    case followRequests
}

enum SheetDestinations: Identifiable {
    case newStatusEditor
    case replyToStatusEditor(status: StatusModel)
    case settings
    case report(objectType: Report.ObjectType, objectId: String)
    case shareImage(image: UIImage)

    public var id: String {
        switch self {
        case .replyToStatusEditor, .newStatusEditor:
            return "statusEditor"
        case .settings:
            return "settings"
        case .report:
            return "report"
        case .shareImage:
            return "shareImage"
        }
    }
}

enum OverlayDestinations {
    case successPayment
}

enum AlertDestinations: Identifiable {
    case alternativeText(text: String)
    case savePhotoSuccess

    public var id: String {
        switch self {
        case .alternativeText:
            return "alternativeText"
        case .savePhotoSuccess:
            return "savePhotoSuccess"
        }
    }
}

@MainActor
class RouterPath: ObservableObject {
    public var urlHandler: ((URL) -> OpenURLAction.Result)?

    @Published public var path: [RouteurDestinations] = []
    @Published public var presentedSheet: SheetDestinations?
    @Published public var presentedOverlay: OverlayDestinations?
    @Published public var presentedAlert: AlertDestinations?

    public init() {}

    // swiftlint:disable:next identifier_name
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
            let results = try? await Client.shared.search?.search(query: acct, resultsType: Pixelfed.Search.ResultsType.accounts)

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
