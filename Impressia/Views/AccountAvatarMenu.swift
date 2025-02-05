//
//  https://mczachurski.dev
//  Copyright © 2025 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import ClientKit
import EnvironmentKit
import ServicesKit
import SwiftData
import SwiftUI

@MainActor
struct AccountAvatarMenu: View {
    @Environment(\.modelContext) private var modelContext

    @Environment(ApplicationState.self) var applicationState
    @Environment(Client.self) var client
    @Environment(RouterPath.self) var routerPath

    @Query(sort: \AccountData.acct, order: .forward) var dbAccounts: [AccountData]

    @Binding var viewMode: MainView.ViewMode

    var body: some View {
        Menu {
            ForEach(self.dbAccounts) { account in
                Button {
                    self.switchAccounts(account)
                } label: {
                    HStack {
                        Text(account.displayName ?? account.acct)
                        self.getAvatarImage(avatarUrl: account.avatar, avatarData: account.avatarData)
                    }
                }
                .disabled(account.id == self.applicationState.account?.id)
            }

            Divider()

            Button {
                HapticService.shared.fireHaptic(of: .buttonPress)
                self.routerPath.presentedSheet = .settings
            } label: {
                Label("mainview.menu.settings", systemImage: "gear")
            }
        } label: {
            self.getAvatarImage(avatarUrl: self.applicationState.account?.avatar,
                                avatarData: self.applicationState.account?.avatarData)
        }
    }

    @ViewBuilder
    private func getAvatarImage(avatarUrl: URL?, avatarData: Data?) -> some View {
        if let avatarData,
           let uiImage = UIImage(data: avatarData)?.roundedAvatar(avatarShape: self.applicationState.avatarShape) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: 32.0, height: 32.0)
                .clipShape(self.applicationState.avatarShape.shape())
        } else if let avatarUrl {
            AsyncImage(url: avatarUrl)
                .frame(width: 32.0, height: 32.0)
                .clipShape(self.applicationState.avatarShape.shape())
        } else {
            Image(systemName: "person")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.customGrayColor)
                .clipShape(AvatarShape.circle.shape())
                .background(
                    AvatarShape.circle.shape()
                )
        }
    }

    private func switchAccounts(_ account: AccountData) {
        HapticService.shared.fireHaptic(of: .buttonPress)

        if viewMode == .search {
            self.hideKeyboard()
            self.asyncAfter(0.3) {
                self.tryToSwitch(account)
            }
        } else {
            self.tryToSwitch(account)
        }
    }

    private func tryToSwitch(_ account: AccountData) {
        Task {
            // Verify access token correctness.
            let authorizationSession = AuthorizationSession()
            let accountModel = account.toAccountModel()

            await AuthorizationService.shared.verifyAccount(session: authorizationSession,
                                                            accountModel: accountModel,
                                                            modelContext: modelContext) { signedInAccountModel in
                guard let signedInAccountModel else {
                    ToastrService.shared.showError(title: "", subtitle: NSLocalizedString("mainview.error.switchAccounts", comment: "Cannot switch accounts."))
                    return
                }

                Task { @MainActor in
                    let instance = try? await self.client.instances.instance(url: signedInAccountModel.serverUrl)

                    // Refresh client state.
                    self.client.setAccount(account: signedInAccountModel)

                    // Refresh application state.
                    self.applicationState.changeApplicationState(accountModel: signedInAccountModel,
                                                                 instance: instance,
                                                                 lastSeenStatusId: signedInAccountModel.lastSeenStatusId,
                                                                 lastSeenNotificationId: signedInAccountModel.lastSeenNotificationId)

                    // Set account as default (application will open this account after restart).
                    ApplicationSettingsHandler.shared.set(accountId: signedInAccountModel.id, modelContext: modelContext)

                    // Refresh new photos and notifications.
                    _ = await (self.calculateNewPhotosInBackground(), self.calculateNewNotificationsInBackground())
                }
            }
        }
    }

    private func calculateNewPhotosInBackground() async {
        self.applicationState.amountOfNewStatuses = await HomeTimelineService.shared.amountOfNewStatuses(
            includeReblogs: self.applicationState.showReboostedStatuses,
            hideStatusesWithoutAlt: self.applicationState.hideStatusesWithoutAlt,
            modelContext: modelContext
        )
    }

    private func calculateNewNotificationsInBackground() async {
        self.applicationState.amountOfNewNotifications = await NotificationsService.shared.amountOfNewNotifications(modelContext: modelContext)
    }
}
