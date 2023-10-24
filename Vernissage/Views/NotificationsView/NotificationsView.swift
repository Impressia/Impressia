//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import ServicesKit
import EnvironmentKit
import WidgetsKit

@MainActor
struct NotificationsView: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(Client.self) var client
    @Environment(\.modelContext) private var modelContext

    @State var accountId: String
    @State private var notifications: [PixelfedKit.Notification] = []
    @State private var allItemsLoaded = false
    @State private var state: ViewState = .loading

    @State private var minId: String?
    @State private var maxId: String?

    private let defaultPageSize = 40

    var body: some View {
        self.mainBody()
            .navigationTitle("notifications.navigationBar.title")
    }

    @ViewBuilder
    private func mainBody() -> some View {
        switch state {
        case .loading:
            LoadingIndicator()
                .task {
                    await self.loadNotifications()
                }
        case .loaded:
            if self.notifications.isEmpty {
                NoDataView(imageSystemName: "bell", text: "notifications.title.noNotifications")
            } else {
                self.list()
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                await self.loadMoreNotifications()
            }
            .padding()
        }
    }

    @ViewBuilder
    private func list() -> some View {
        List {
            ForEach(notifications, id: \.id) { notification in
                NotificationRowView(notification: notification)
            }

            if allItemsLoaded == false {
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
        }
        .listStyle(PlainListStyle())
        .refreshable {
            HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.3))
            await self.refreshNotifications()
            HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.7))
        }
    }

    func loadNotifications() async {
        do {
            if let linkable = try await self.client.notifications?.notifications(maxId: maxId, minId: minId, limit: 5) {
                self.minId = linkable.link?.minId
                self.maxId = linkable.link?.maxId
                self.notifications = linkable.data

                if linkable.data.isEmpty {
                    self.allItemsLoaded = true
                }

                withAnimation {
                    self.state = .loaded
                }
                
                try AccountDataHandler.shared.update(lastSeenNotificationId: linkable.data.first?.id, applicationState: self.applicationState, modelContext: modelContext)

                // Refresh infomation about viewed notifications.
                self.applicationState.amountOfNewNotifications = 0
                try? await NotificationsService.shared.setBadgeCount(0)
            }
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "notifications.error.loadingNotificationsFailed", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "notifications.error.loadingNotificationsFailed", showToastr: false)
            }
        }
    }

    private func loadMoreNotifications() async {
        do {
            if let linkable = try await self.client.notifications?.notifications(maxId: self.maxId, limit: self.defaultPageSize) {
                if linkable.data.isEmpty {
                    self.allItemsLoaded = true
                    return
                }

                self.maxId = linkable.link?.maxId
                self.notifications.append(contentsOf: linkable.data)
            }
        } catch {
            ErrorService.shared.handle(error, message: "notifications.error.loadingNotificationsFailed", showToastr: !Task.isCancelled)
        }
    }

    private func refreshNotifications() async {
        do {
            if let linkable = try await self.client.notifications?.notifications(minId: self.minId, limit: self.defaultPageSize) {
                if let first = linkable.data.first, self.notifications.contains(where: { notification in notification.id == first.id }) {
                    // We have all notifications, we don't have to do anything.
                    return
                }

                try AccountDataHandler.shared.update(lastSeenNotificationId: linkable.data.first?.id, applicationState: self.applicationState, modelContext: modelContext)
                
                // Refresh infomation about viewed notifications.
                self.applicationState.amountOfNewNotifications = 0
                try? await NotificationsService.shared.setBadgeCount(0)

                self.minId = linkable.link?.minId
                self.notifications.insert(contentsOf: linkable.data, at: 0)
            }
        } catch {
            ErrorService.shared.handle(error, message: "notifications.error.loadingNotificationsFailed", showToastr: !Task.isCancelled)
        }
    }
}
