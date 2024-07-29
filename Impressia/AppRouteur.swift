//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import WidgetsKit

@MainActor
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
            case .editProfile:
                EditProfileView()
            case .instance:
                InstanceView()
            case .followRequests:
                FollowRequestsView()
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
            case .report(let objectType, let objectId):
                ReportView(objectType: objectType, objectId: objectId)
            case .shareImage(let image):
                ActivityView(image: image)
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

    func withAlertDestinations(alertDestinations: Binding<AlertDestinations?>) -> some View {
        self.alert(item: alertDestinations) { destination in
            switch destination {
            case .alternativeText(let text):
                return Alert(title: Text("status.title.mediaDescription", comment: "Media description"),
                      message: Text(text),
                      dismissButton: .default(Text("global.title.close", comment: "Close")))
            case .savePhotoSuccess:
                return Alert(title: Text("global.title.success", comment: "Success"),
                      message: Text("global.title.photoSaved", comment: "Photo has been saved"),
                      dismissButton: .default(Text("global.title.ok", comment: "OK")))
            }
        }
    }
}
