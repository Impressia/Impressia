//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

extension View {
    func withAppRouteur() -> some View {
        self.navigationDestination(for: RouteurDestinations.self) { destination in
            switch destination {
            case .tag(let hashTag):
                StatusesView(listType: .hashtag(tag: hashTag))
            case .status(let id, let blurhash, let highestImageUrl, let metaImageWidth, let metaImageHeight):
                StatusView(statusId: id,
                           imageBlurhash: blurhash,
                           highestImageUrl: highestImageUrl,
                           imageWidth: metaImageWidth,
                           imageHeight: metaImageHeight)
            case .statuses(let listType):
                StatusesView(listType: listType)
            case .bookmarks:
                PaginableStatusesView(listType: .bookmarks)
            case .favourites:
                PaginableStatusesView(listType: .favourites)
            case .userProfile(let accountId, let accountDisplayName, let accountUserName):
                UserProfileView(
                    accountId: accountId,
                    accountDisplayName: accountDisplayName,
                    accountUserName: accountUserName)
            case .accounts(let listType):
                AccountsView(listType: listType)
            case .signIn:
                SignInView()
            case .thirdParty:
                ThirdPartyView()
            case .photoEditor(let photoAttachment):
                PhotoEditorView(photoAttachment: photoAttachment)
            case .hashtags(let listType):
                HashtagsView(listType: listType)
            case .accountsPhoto(let listType):
                AccountsPhotoView(listType: listType)
            case .search:
                SearchView()
            }
        }
    }
  
    func withSheetDestinations(sheetDestinations: Binding<SheetDestinations?>) -> some View {
        self.sheet(item: sheetDestinations) { destination in
            switch destination {
            case .replyToStatusEditor(let status):
                ComposeView(statusViewModel: status)
            case .newStatusEditor:
                ComposeView()
            case .settings:
                SettingsView()
            }
        }
    }
    
    func withOverlayDestinations(overlayDestinations: Binding<OverlayDestinations?>) -> some View {
        self.overlay {
            switch overlayDestinations.wrappedValue {
            case .successPayment:
                ThanksView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            default:
                EmptyView()
            }
        }
    }
}
