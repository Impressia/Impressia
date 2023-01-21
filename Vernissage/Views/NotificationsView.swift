//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit

struct NotificationsView: View {
    @EnvironmentObject var applicationState: ApplicationState

    @State var accountId: String
    @State private var notifications: [MastodonKit.Notification] = []
    @State private var allItemsLoaded = false
    @State private var firstLoadFinished = false
    
    @State private var minId: String?
    @State private var maxId: String?
    
    private let defaultPageSize = 20
    
    var body: some View {
        List {
            ForEach(notifications, id: \.id) { notification in
                switch notification.type {
                case .mention, .reblog, .favourite:
                    if let status = notification.status {
                        NavigationLink(destination: StatusView(statusId: status.id)
                            .environmentObject(applicationState)) {
                                NotificationRow(notification: notification)
                            }
                    }
                case .follow:
                    NavigationLink(destination: UserProfileView(
                        accountId: notification.account.id,
                        accountDisplayName: notification.account.displayName,
                        accountUserName: notification.account.acct)
                        .environmentObject(applicationState)) {
                            NotificationRow(notification: notification)
                        }
                }
            }
            
            if allItemsLoaded == false && firstLoadFinished == true {
                HStack {
                    Spacer()
                    LoadingIndicator()
                        .task {
                            await self.loadMoreNotifications()
                        }
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }.overlay {
            if firstLoadFinished == false {
                LoadingIndicator()
            } else {
                if self.notifications.isEmpty {
                    VStack {
                        Image(systemName: "person.3.sequence")
                            .font(.largeTitle)
                            .padding(.bottom, 4)
                        Text("Unfortunately, there is no one here.")
                            .font(.title3)
                    }.foregroundColor(.lightGrayColor)
                }
            }
        }
        .navigationBarTitle("Notifications")
        .listStyle(PlainListStyle())
        .refreshable {
            await self.loadNewNotifications()
        }
        .task {
            if self.notifications.isEmpty == false {
                return
            }
            
            await self.loadNotifications()
        }
    }
    
    func loadNotifications() async {
        do {
            let linkable = try await NotificationService.shared.getNotifications(
                forAccountId: self.accountId,
                andContext: self.applicationState.accountData,
                maxId: maxId,
                minId: minId,
                limit: 5)
            
            await self.downloadAllImages(notifications: linkable.data)

            self.minId = linkable.link?.minId
            self.maxId = linkable.link?.maxId
            self.notifications = linkable.data

            if linkable.data.isEmpty || linkable.data.count < 5 {
                self.allItemsLoaded = true
            }
            
            self.firstLoadFinished = true
        } catch {
            ErrorService.shared.handle(error, message: "Error during download notifications from server.", showToastr: !Task.isCancelled)
        }
    }
    
    private func loadMoreNotifications() async {
        do {
            let linkable = try await NotificationService.shared.getNotifications(
                forAccountId: self.accountId,
                andContext: self.applicationState.accountData,
                maxId: self.maxId,
                limit: self.defaultPageSize)
            
            await self.downloadAllImages(notifications: linkable.data)

            self.maxId = linkable.link?.maxId
            self.notifications.append(contentsOf: linkable.data)

            if linkable.data.isEmpty || linkable.data.count < self.defaultPageSize {
                self.allItemsLoaded = true
            }
        } catch {
            ErrorService.shared.handle(error, message: "Error during download notifications from server.", showToastr: !Task.isCancelled)
        }
    }
    
    private func loadNewNotifications() async {
        do {
            let linkable = try await NotificationService.shared.getNotifications(
                forAccountId: self.accountId,
                andContext: self.applicationState.accountData,
                minId: self.minId,
                limit: self.defaultPageSize)
            
            if let first = linkable.data.first, self.notifications.contains(where: { notification in notification.id == first.id }) {
                // We have all notifications, we don't have to do anything.
                return
            }
            
            await self.downloadAllImages(notifications: linkable.data)
            
            self.minId = linkable.link?.minId
            var downloaded = linkable.data

            self.notifications.insert(contentsOf: downloaded, at: 0)
        } catch {
            ErrorService.shared.handle(error, message: "Error during download notifications from server.", showToastr: !Task.isCancelled)
        }
    }
    
    private func downloadAllImages(notifications: [MastodonKit.Notification]) async {
        // Download all avatars into cache.
        let accounts = notifications.map({ notification in notification.account })
        await self.downloadAvatars(accounts: accounts)

        // Download all images into cache.
        var images: [(id: String, url: URL)] = []
        for notification in notifications {
            if let mediaAttachment = notification.status?.mediaAttachments {
                images.append(contentsOf:
                    mediaAttachment
                        .filter({ attachment in
                            attachment.type == Attachment.AttachmentType.image
                        })
                        .map({
                            attachment in (id: attachment.id, url: attachment.url)
                        }))
            }
        }

        await self.downloadImages(images: images)
    }
    
    private func downloadAvatars(accounts: [Account]) async {
        await withTaskGroup(of: Void.self) { group in
            for account in accounts {
                group.addTask { await CacheAvatarService.shared.downloadImage(for: account.id, avatarUrl: account.avatar) }
            }
        }
    }
    
    private func downloadImages(images: [(id: String, url: URL)]) async {
        await withTaskGroup(of: Void.self) { group in
            for image in images {
                group.addTask { await CacheImageService.shared.downloadImage(for: image.id, url: image.url) }
            }
        }
    }
}
