//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import UIKit
import CoreData
import PixelfedKit

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath
    @EnvironmentObject var tipsStore: TipsStore

    @State private var navBarTitle: LocalizedStringKey = "mainview.tab.homeTimeline"
    @State private var viewMode: ViewMode = .home {
        didSet {
            self.navBarTitle = self.getViewTitle(viewMode: viewMode)
        }
    }

    @FetchRequest(sortDescriptors: [SortDescriptor(\.acct, order: .forward)]) var dbAccounts: FetchedResults<AccountData>

    private enum ViewMode {
        case home, local, federated, profile, notifications, trendingPhotos, trendingTags, trendingAccounts, search
    }

    var body: some View {
        self.getMainView()
            .navigationMenu(menuPosition: $applicationState.menuPosition) {
                self.navigationMenuContent()
            }
            .navigationTitle(navBarTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                self.getLeadingToolbar()

                if self.applicationState.menuPosition == .top {
                    self.getPrincipalToolbar()
                }

                self.getTrailingToolbar()
            }
            .onChange(of: tipsStore.status) { status in
                if status == .successful {
                    withAnimation(.spring()) {
                        self.routerPath.presentedOverlay = .successPayment
                        self.tipsStore.reset()
                    }
                }
            }
    }

    @ViewBuilder
    private func getMainView() -> some View {
        switch self.viewMode {
        case .home:
            HomeFeedView(accountId: applicationState.account?.id ?? String.empty())
                .id(applicationState.account?.id ?? String.empty())
        case .trendingPhotos:
            TrendStatusesView(accountId: applicationState.account?.id ?? String.empty())
                .id(applicationState.account?.id ?? String.empty())
        case .trendingTags:
            HashtagsView(listType: .trending)
                .id(applicationState.account?.id ?? String.empty())
        case .trendingAccounts:
            AccountsPhotoView(listType: .trending)
                .id(applicationState.account?.id ?? String.empty())
        case .local:
            StatusesView(listType: .local)
                .id(applicationState.account?.id ?? String.empty())
        case .federated:
            StatusesView(listType: .federated)
                .id(applicationState.account?.id ?? String.empty())
        case .profile:
            if let accountData = self.applicationState.account {
                UserProfileView(accountId: accountData.id,
                                accountDisplayName: accountData.displayName,
                                accountUserName: accountData.acct)
                .id(applicationState.account?.id ?? String.empty())
            }
        case .notifications:
            if let accountData = self.applicationState.account {
                NotificationsView(accountId: accountData.id)
                    .id(applicationState.account?.id ?? String.empty())
            }
        case .search:
            SearchView()
                .id(applicationState.account?.id ?? String.empty())
        }
    }

    @ToolbarContentBuilder
    private func getPrincipalToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Menu {
                self.navigationMenuContent()
            } label: {
                HStack {
                    Text(navBarTitle, comment: "Navbar title")
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .fontWeight(.semibold)
                        .font(.subheadline)
                }
                .frame(width: 150)
                .foregroundColor(.mainTextColor)
            }
        }
    }

    @ToolbarContentBuilder
    private func getLeadingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
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
    }

    @ToolbarContentBuilder
    private func getTrailingToolbar() -> some ToolbarContent {
        if viewMode == .local || viewMode == .home || viewMode == .federated || viewMode == .trendingPhotos || viewMode == .search {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticService.shared.fireHaptic(of: .buttonPress)
                    self.routerPath.presentedSheet = .newStatusEditor
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(Color.mainTextColor)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder
    private func navigationMenuContent() -> some View {
        Button {
            self.switchView(to: .home)
        } label: {
            HStack {
                Text(self.getViewTitle(viewMode: .home))
                Image(systemName: "house")
            }
        }

        Button {
            self.switchView(to: .local)
        } label: {
            HStack {
                Text(self.getViewTitle(viewMode: .local))
                Image(systemName: "building")
            }
        }

        Button {
            self.switchView(to: .federated)
        } label: {
            HStack {
                Text(self.getViewTitle(viewMode: .federated))
                Image(systemName: "globe.europe.africa")
            }
        }

        Button {
            self.switchView(to: .search)
        } label: {
            HStack {
                Text(self.getViewTitle(viewMode: .search))
                Image(systemName: "magnifyingglass")
            }
        }

        Divider()

        Menu {
            Button {
                self.switchView(to: .trendingPhotos)
            } label: {
                HStack {
                    Text(self.getViewTitle(viewMode: .trendingPhotos))
                    Image(systemName: "photo.stack")
                }
            }

            Button {
                self.switchView(to: .trendingTags)
            } label: {
                HStack {
                    Text(self.getViewTitle(viewMode: .trendingTags))
                    Image(systemName: "tag")
                }
            }

            Button {
                self.switchView(to: .trendingAccounts)
            } label: {
                HStack {
                    Text(self.getViewTitle(viewMode: .trendingAccounts))
                    Image(systemName: "person.3")
                }
            }
        } label: {
            HStack {
                Text("mainview.tab.trending", comment: "Trending menu section")
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
        }

        Divider()

        Button {
            self.switchView(to: .profile)
        } label: {
            HStack {
                Text(self.getViewTitle(viewMode: .profile))
                Image(systemName: "person.crop.circle")
            }
        }

        Button {
            self.switchView(to: .notifications)
        } label: {
            HStack {
                Text(self.getViewTitle(viewMode: .notifications))
                Image(systemName: "bell.badge")
            }
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
                .background(Color.lightGrayColor)
                .clipShape(AvatarShape.circle.shape())
                .background(
                    AvatarShape.circle.shape()
                )
        }
    }

    private func getViewTitle(viewMode: ViewMode) -> LocalizedStringKey {
        switch viewMode {
        case .home:
            return "mainview.tab.homeTimeline"
        case .trendingPhotos:
            return "mainview.tab.trendingPhotos"
        case .trendingTags:
            return "mainview.tab.trendingTags"
        case .trendingAccounts:
            return "mainview.tab.trendingAccounts"
        case .local:
            return "mainview.tab.localTimeline"
        case .federated:
            return "mainview.tab.federatedTimeline"
        case .profile:
            return "mainview.tab.userProfile"
        case .notifications:
            return "mainview.tab.notifications"
        case .search:
            return "mainview.tab.search"
        }
    }

    private func switchView(to newViewMode: ViewMode) {
        HapticService.shared.fireHaptic(of: .tabSelection)

        if viewMode == .search {
            hideKeyboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.viewMode = newViewMode
            }
        } else {
            self.viewMode = newViewMode
        }
    }

    private func switchAccounts(_ account: AccountData) {
        HapticService.shared.fireHaptic(of: .buttonPress)

        if viewMode == .search {
            hideKeyboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
            let accountModel = AccountModel(accountData: account)

            await AuthorizationService.shared.verifyAccount(session: authorizationSession, accountModel: accountModel) { signedInAccountModel in
                guard let signedInAccountModel else {
                    ToastrService.shared.showError(subtitle: "mainview.error.switchAccounts")
                    return
                }

                Task { @MainActor in
                    let instance = try? await self.client.instances.instance(url: signedInAccountModel.serverUrl)

                    // Refresh client state.
                    self.client.setAccount(account: signedInAccountModel)

                    // Refresh application state.
                    self.applicationState.changeApplicationState(accountModel: signedInAccountModel,
                                                                 instance: instance,
                                                                 lastSeenStatusId: signedInAccountModel.lastSeenStatusId)

                    // Set account as default (application will open this account after restart).
                    ApplicationSettingsHandler.shared.set(accountId: signedInAccountModel.id)
                }
            }
        }
    }
}
