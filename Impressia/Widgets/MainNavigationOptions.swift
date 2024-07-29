//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import EnvironmentKit

struct MainNavigationOptions: View {
    @Environment(ApplicationState.self) var applicationState

    let onViewModeIconTap: (MainView.ViewMode) -> Void

    @Binding var hiddenMenuItems: [MainView.ViewMode]

    init(hiddenMenuItems: Binding<[MainView.ViewMode]>, onViewModeIconTap: @escaping (MainView.ViewMode) -> Void) {
        self._hiddenMenuItems = hiddenMenuItems
        self.onViewModeIconTap = onViewModeIconTap
    }

    var body: some View {
        if !self.hiddenMenuItems.contains(where: { $0 == .home }) {
            Button {
                self.onViewModeIconTap(.home)
            } label: {
                HStack {
                    Text(MainView.ViewMode.home.title)
                    MainView.ViewMode.home.getImage(applicationState: applicationState)
                }
            }
        }

        if !self.hiddenMenuItems.contains(where: { $0 == .local }) {
            Button {
                self.onViewModeIconTap(.local)
            } label: {
                HStack {
                    Text(MainView.ViewMode.local.title)
                    MainView.ViewMode.local.getImage(applicationState: applicationState)
                }
            }
        }

        if !self.hiddenMenuItems.contains(where: { $0 == .federated }) {
            Button {
                self.onViewModeIconTap(.federated)
            } label: {
                HStack {
                    Text(MainView.ViewMode.federated.title)
                    MainView.ViewMode.federated.getImage(applicationState: applicationState)
                }
            }
        }

        if !self.hiddenMenuItems.contains(where: { $0 == .search }) {
            Button {
                self.onViewModeIconTap(.search)
            } label: {
                HStack {
                    Text(MainView.ViewMode.search.title)
                    MainView.ViewMode.search.getImage(applicationState: applicationState)
                }
            }
        }

        Divider()

        Menu {
            Button {
                self.onViewModeIconTap(.trendingPhotos)
            } label: {
                HStack {
                    Text(MainView.ViewMode.trendingPhotos.title)
                    MainView.ViewMode.trendingPhotos.getImage(applicationState: applicationState)
                }
            }

            Button {
                self.onViewModeIconTap(.trendingTags)
            } label: {
                HStack {
                    Text(MainView.ViewMode.trendingTags.title)
                    MainView.ViewMode.trendingTags.getImage(applicationState: applicationState)
                }
            }

            Button {
                self.onViewModeIconTap(.trendingAccounts)
            } label: {
                HStack {
                    Text(MainView.ViewMode.trendingAccounts.title)
                    MainView.ViewMode.trendingAccounts.getImage(applicationState: applicationState)
                }
            }
        } label: {
            HStack {
                Text("mainview.tab.trending", comment: "Trending menu section")
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
        }

        Divider()

        if !self.hiddenMenuItems.contains(where: { $0 == .profile }) {
            Button {
                self.onViewModeIconTap(.profile)
            } label: {
                HStack {
                    Text(MainView.ViewMode.profile.title)
                    MainView.ViewMode.profile.getImage(applicationState: applicationState)
                }
            }
        }

        if !self.hiddenMenuItems.contains(where: { $0 == .notifications }) {
            Button {
                self.onViewModeIconTap(.notifications)
            } label: {
                HStack {
                    Text(MainView.ViewMode.notifications.title)
                    MainView.ViewMode.notifications.getImage(applicationState: applicationState)
                }
            }
        }
    }
}
