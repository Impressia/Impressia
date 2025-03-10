//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import UIKit
import PixelfedKit
import ServicesKit
import EnvironmentKit
import WidgetsKit

@MainActor
struct MainView: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(RouterPath.self) var routerPath
    @Environment(TipsStore.self) var tipsStore

    @State private var navBarTitle: LocalizedStringKey = ViewMode.home.title
    @State private var viewMode: ViewMode = .home {
        didSet {
            self.navBarTitle = viewMode.title
        }
    }

    private let mainNavigationTip = MainNavigationTip()

    public enum ViewMode: Int, Identifiable {
        case home = 1
        case local = 2
        case federated = 3
        case search = 4
        case profile = 5
        case notifications = 6
        case trendingPhotos = 7
        case trendingTags = 8
        case trendingAccounts = 9
        case bookmarks = 10
        case favourites = 11

        var id: Self {
            return self
        }
        
        public var title: LocalizedStringKey {
            switch self {
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
            case .bookmarks:
                return "userProfile.title.bookmarks"
            case .favourites:
                return "userProfile.title.favourites"
            }
        }

        @ViewBuilder
        public func getImage(applicationState: ApplicationState) -> some View {
            switch self {
            case .home:
                Image(systemName: "house")
            case .trendingPhotos:
                Image(systemName: "photo.stack")
            case .trendingTags:
                Image(systemName: "tag")
            case .trendingAccounts:
                Image(systemName: "person.crop.rectangle.stack")
            case .local:
                Image(systemName: "building")
            case .federated:
                Image(systemName: "globe.europe.africa")
            case .profile:
                Image(systemName: "person.crop.circle")
            case .notifications:
                if applicationState.menuPosition == .top {
                    applicationState.amountOfNewNotifications > 0 ? Image(systemName: "bell.badge") : Image(systemName: "bell")
                } else {
                    applicationState.amountOfNewNotifications > 0
                    ? AnyView(
                        Image(systemName: "bell.badge")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(applicationState.tintColor.color().opacity(0.75), Color.mainTextColor.opacity(0.75)))
                    : AnyView(Image(systemName: "bell"))
                }
            case .search:
                Image(systemName: "magnifyingglass")
            case .bookmarks:
                Image(systemName: "bookmark")
            case .favourites:
                Image(systemName: "star")
            }
        }
    }

    var body: some View {
        @Bindable var applicationState = applicationState
        @Bindable var routerPath = routerPath

        NavigationStack(path: $routerPath.path) {
            self.getMainView()
                .navigationMenuButtons(menuPosition: $applicationState.menuPosition, viewMode: $viewMode) { viewMode in
                    self.switchView(to: viewMode)
                }
                .navigationTitle(navBarTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    self.getLeadingToolbar()
                    
                    if self.applicationState.menuPosition == .top {
                        self.getPrincipalToolbar()
                        self.getTrailingToolbar()
                    }
                }
                .onChange(of: tipsStore.status) { oldStatus, newStatus in
                    if newStatus == .successful {
                        withAnimation(.spring()) {
                            self.routerPath.presentedOverlay = .successPayment
                            self.tipsStore.reset()
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private func getMainView() -> some View {
        switch self.viewMode {
        case .home:
            if UIDevice.isIPhone {
                HomeTimelineView()
                    .id(applicationState.account?.id ?? String.empty())
            } else {
                StatusesView(listType: .home)
                    .id(applicationState.account?.id ?? String.empty())
            }
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
        case .bookmarks:
            StatusesView(listType: .bookmarks)
                .id(applicationState.account?.id ?? String.empty())
        case .favourites:
            StatusesView(listType: .favourites)
                .id(applicationState.account?.id ?? String.empty())
        }
    }

    @ToolbarContentBuilder
    private func getPrincipalToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Menu {
                MainNavigationOptions(hiddenMenuItems: Binding.constant([])) { viewMode in
                    self.switchView(to: viewMode)
                }
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
                .popoverTip(self.mainNavigationTip)
            }
        }
    }

    @ToolbarContentBuilder
    private func getLeadingToolbar() -> some ToolbarContent {
        if applicationState.menuPosition == .top {
            @Bindable var applicationState = applicationState

            ToolbarItem(placement: .navigationBarLeading) {
                AccountAvatarMenu(menuPosition: $applicationState.menuPosition, viewMode: $viewMode)
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
                    Image(systemName: "plus")
                        .foregroundColor(Color.mainTextColor)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func switchView(to newViewMode: ViewMode) {
        HapticService.shared.fireHaptic(of: .tabSelection)

        if viewMode == .search {
            self.hideKeyboard()
            self.asyncAfter(0.3) {
                self.viewMode = newViewMode
            }
        } else {
            self.viewMode = newViewMode
        }
    }
}
