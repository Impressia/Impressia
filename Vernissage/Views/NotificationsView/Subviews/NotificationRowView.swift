//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import NukeUI
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct NotificationRowView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var routerPath: RouterPath
    @EnvironmentObject var client: Client

    @State private var image: SwiftUI.Image?

    private var attachment: MediaAttachment?
    private var notification: PixelfedKit.Notification

    public init(notification: PixelfedKit.Notification) {
        self.notification = notification
        self.attachment = notification.status?.getAllImageMediaAttachments().first

        if let attachment, let previewUrl = attachment.previewUrl, let imageFromCache = CacheImageService.shared.get(for: previewUrl) {
            self.image = imageFromCache
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ZStack {
                HStack {
                    Spacer()
                    UserAvatar(accountAvatar: self.notification.account.avatar, size: .list)
                        .onTapGesture {
                            self.routerPath.navigate(to: .userProfile(accountId: notification.account.id,
                                                                      accountDisplayName: notification.account.displayNameWithoutEmojis,
                                                                      accountUserName: notification.account.acct))
                        }
                }
                self.notificationBadge()
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text(self.notification.account.displayNameWithoutEmojis)
                        .foregroundColor(.mainTextColor)
                        .font(.footnote)
                        .fontWeight(.bold)

                    Spacer()

                    if let createdAt = self.notification.createdAt.toDate(.isoDateTimeMilliSec) {
                        RelativeTime(date: createdAt)
                            .foregroundColor(.lightGrayColor)
                            .font(.footnote)
                    }
                }

                Text(self.getTitle(), comment: "Notification type")
                    .foregroundColor(.lightGrayColor)
                    .font(.footnote)
                    .fontWeight(.light)

                switch self.notification.type {
                case .favourite, .reblog, .status, .poll, .update:
                    HStack(alignment: .top) {
                        Spacer()
                        if let attachment {
                            if let cachedImage = self.image {
                                cachedImage
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                BlurredImage(blurhash: attachment.blurhash)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .task {
                                        await CacheImageService.shared.download(url: attachment.previewUrl)
                                        if let previewUrl = attachment.previewUrl, let imageFromCache = CacheImageService.shared.get(for: previewUrl) {
                                            self.image = imageFromCache
                                        }
                                    }
                            }
                        } else {
                            EmptyView()
                        }
                    }
                case .mention:
                    if let status = self.notification.status {
                        MarkdownFormattedText(status.content.asMarkdown)
                            .font(.caption)
                            .environment(\.openURL, OpenURLAction { _ in .handled })
                    } else {
                        EmptyView()
                    }
                case .follow, .followRequest, .adminSignUp:
                    if let note = self.notification.account.note {
                        MarkdownFormattedText(note.asMarkdown)
                            .font(.caption)
                            .environment(\.openURL, OpenURLAction { _ in .handled })
                    } else {
                        EmptyView()
                    }
                case .adminReport:
                    Text(self.notification.report?.type.rawValue ?? "")
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            switch notification.type {
            case .favourite, .reblog, .mention, .status, .poll, .update:
                if let status = notification.status {
                    let statusModel = StatusModel(status: status)
                    self.routerPath.navigate(to: .status(id: statusModel.id,
                                                         blurhash: statusModel.mediaAttachments.first?.blurhash,
                                                         highestImageUrl: statusModel.mediaAttachments.getHighestImage()?.url,
                                                         metaImageWidth: statusModel.getImageWidth(),
                                                         metaImageHeight: statusModel.getImageHeight()))
                }
            case .follow, .followRequest, .adminSignUp:
                self.routerPath.navigate(to: .userProfile(accountId: notification.account.id,
                                                          accountDisplayName: notification.account.displayNameWithoutEmojis,
                                                          accountUserName: notification.account.acct))
            case .adminReport:
                if let objectType = notification.report?.objectType, let objectId = notification.report?.objectId {
                    switch objectType {
                    case .user:
                        self.routerPath.navigate(to: .userProfile(accountId: objectId, accountDisplayName: "", accountUserName: ""))
                    case .post:
                        self.routerPath.navigate(to: .status(id: objectId))
                    }

                }
            }
        }
    }

    private func notificationBadge() -> some View {
        VStack {
            HStack {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.85), lineWidth: 2)
                        .background(Circle().fill(self.getColor().opacity(0.85)))
                        .frame(width: 28, height: 28)
                    self.getImage()
                        .foregroundColor(.white)
                        .font(.caption)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            Spacer()
        }
    }

    private func getTitle() -> LocalizedStringKey {
        switch notification.type {
        case .follow:
            return "notifications.title.followedYou"
        case .mention:
            return "notifications.title.mentionedYou"
        case .reblog:
            return "notifications.title.boosted"
        case .favourite:
            return "notifications.title.favourited"
        case .status:
            return "notifications.title.postedStatus"
        case .followRequest:
            return "notifications.title.followRequest"
        case .poll:
            return "notifications.title.poll"
        case .update:
            return "notifications.title.updatedStatus"
        case .adminSignUp:
            return "notifications.title.signedUp"
        case .adminReport:
            return "notifications.title.newReport"
        }
    }

    private func getImage() -> Image {
        switch notification.type {
        case .follow:
            return Image(systemName: "person.badge.plus")
        case .mention:
            return Image(systemName: "at")
        case .reblog:
            return Image("custom.rocket")
        case .favourite:
            return Image(systemName: "star")
        case .status:
            return Image(systemName: "photo.on.rectangle.angled")
        case .followRequest:
            return Image(systemName: "person.badge.clock")
        case .poll:
            return Image(systemName: "checklist")
        case .update:
            return Image(systemName: "text.below.photo")
        case .adminSignUp:
            return Image(systemName: "person.badge.key")
        case .adminReport:
            return Image(systemName: "exclamationmark.bubble")
        }
    }

    private func getColor() -> Color {
        switch notification.type {
        case .follow:
            return Color.accentColor3
        case .mention:
            return Color.accentColor4
        case .reblog:
            return Color.accentColor5
        case .favourite:
            return Color.accentColor6
        case .status:
            return Color.accentColor1
        case .followRequest:
            return Color.accentColor2
        case .poll:
            return Color.accentColor7
        case .update:
            return Color.accentColor8
        case .adminSignUp:
            return Color.accentColor9
        case .adminReport:
            return Color.accentColor10
        }
    }
}
