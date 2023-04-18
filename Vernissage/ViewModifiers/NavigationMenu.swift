//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import EnvironmentKit
import ServicesKit

extension View {
    func navigationMenu<MenuItems>(menuPosition: Binding<MenuPosition>,
                                   onViewModeIconTap: @escaping (MainView.ViewMode) -> Void,
                                   @ViewBuilder menuItems: @escaping () -> MenuItems) -> some View where MenuItems: View {
        modifier(NavigationMenu(menuPosition: menuPosition, onViewModeIconTap: onViewModeIconTap, menuItems: menuItems))
    }
}

private struct NavigationMenu<MenuItems>: ViewModifier where MenuItems: View {
    @EnvironmentObject var routerPath: RouterPath

    private let menuItems: () -> MenuItems
    private let onViewModeIconTap: (MainView.ViewMode) -> Void
    private let imageFontSize = 20.0

    private let customMenuItems = [
        NavigationMenuItemDetails(id: 1, viewMode: .home, title: "mainview.tab.homeTimeline", image: "house"),
        NavigationMenuItemDetails(id: 2, viewMode: .local, title: "mainview.tab.localTimeline", image: "building"),
        NavigationMenuItemDetails(id: 3, viewMode: .federated, title: "mainview.tab.federatedTimeline", image: "globe.europe.africa"),
        NavigationMenuItemDetails(id: 4, viewMode: .search, title: "mainview.tab.search", image: "magnifyingglass"),
        NavigationMenuItemDetails(id: 5, viewMode: .profile, title: "mainview.tab.userProfile", image: "person.crop.circle"),
        NavigationMenuItemDetails(id: 6, viewMode: .notifications, title: "mainview.tab.notifications", image: "bell.badge")
    ]

    @State private var selectedCustomMenuItems = [
        NavigationMenuItemDetails(id: 1, viewMode: .home, title: "mainview.tab.homeTimeline", image: "house"),
        NavigationMenuItemDetails(id: 2, viewMode: .local, title: "mainview.tab.localTimeline", image: "building"),
        NavigationMenuItemDetails(id: 3, viewMode: .profile, title: "mainview.tab.userProfile", image: "person.crop.circle")
    ]

    @Binding var menuPosition: MenuPosition

    init(menuPosition: Binding<MenuPosition>, onViewModeIconTap: @escaping (MainView.ViewMode) -> Void, @ViewBuilder menuItems: @escaping () -> MenuItems) {
        self.menuItems = menuItems
        self.onViewModeIconTap = onViewModeIconTap
        self._menuPosition = menuPosition
    }

    func body(content: Content) -> some View {
        if self.menuPosition == .top {
            content
        } else {
            ZStack {
                content

                VStack(alignment: .trailing) {
                    Spacer()
                    HStack(alignment: .center) {
                        if self.menuPosition == .bottomRight {
                            Spacer()

                            self.menuContainerView()
                                .padding(.trailing, 24)
                                .padding(.bottom, 10)
                        }

                        if self.menuPosition == .bottomLeft {
                            self.menuContainerView()
                                .padding(.leading, 24)
                                .padding(.bottom, 10)

                            Spacer()
                        }
                    }
                }
                .onAppear {
                    self.loadCustomMenuItems()
                }
            }
        }
    }

    @ViewBuilder
    private func menuContainerView() -> some View {
        if self.menuPosition == .bottomRight {
            HStack(alignment: .center) {
                HStack {
                    self.contextMenuView()
                    self.customMenuItemsView()
                }
                .frame(height: 50)
                .padding(.horizontal, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

                self.composeImageView()
                    .frame(height: 50)
                    .padding(.horizontal, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        } else {
            HStack(alignment: .center) {
                self.composeImageView()
                    .frame(height: 50)
                    .padding(.horizontal, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())

                HStack {
                    self.customMenuItemsView()
                    self.contextMenuView()
                }
                .frame(height: 50)
                .padding(.horizontal, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
        }
    }

    @ViewBuilder
    private func contextMenuView() -> some View {
        Menu {
            self.menuItems()
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: self.imageFontSize))
                .foregroundColor(.mainTextColor.opacity(0.75))
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
        }
    }

    @ViewBuilder
    private func customMenuItemsView() -> some View {
        ForEach(self.selectedCustomMenuItems) { item in
            self.customMenuItemView(customMenuItem: item)
        }
    }

    @ViewBuilder
    private func composeImageView() -> some View {
        Button {
            HapticService.shared.fireHaptic(of: .buttonPress)
            self.routerPath.presentedSheet = .newStatusEditor
        } label: {
            Image(systemName: "plus")
                .font(.system(size: self.imageFontSize))
                .foregroundColor(.mainTextColor.opacity(0.75))
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
        }
    }

    @ViewBuilder
    private func customMenuItemView(customMenuItem: NavigationMenuItemDetails) -> some View {
        Button {
            self.onViewModeIconTap(customMenuItem.viewMode)
        } label: {
            Image(systemName: customMenuItem.image)
                .font(.system(size: self.imageFontSize))
                .foregroundColor(.mainTextColor.opacity(0.75))
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
        }.contextMenu {
            self.listOfIconsView(customMenuItem: customMenuItem)
        }
    }

    @ViewBuilder
    private func listOfIconsView(customMenuItem: NavigationMenuItemDetails) -> some View {
        ForEach(self.customMenuItems) { item in
            Button {
                withAnimation {
                    customMenuItem.title = item.title
                    customMenuItem.viewMode = item.viewMode
                    customMenuItem.image = item.image
                }

                // Saving in core data.
                switch customMenuItem.id {
                case 1:
                    ApplicationSettingsHandler.shared.set(customNavigationMenuItem1: item.id)
                case 2:
                    ApplicationSettingsHandler.shared.set(customNavigationMenuItem2: item.id)
                case 3:
                    ApplicationSettingsHandler.shared.set(customNavigationMenuItem3: item.id)
                default:
                    break
                }
            } label: {
                Label(NSLocalizedString(item.title, comment: "Custom menu item"), systemImage: item.image)
            }
        }
    }

    private func loadCustomMenuItems() {
        let applicationSettings = ApplicationSettingsHandler.shared.get()

        self.setCustomMenuItem(menuId: 1, savedId: Int(applicationSettings.customNavigationMenuItem1))
        self.setCustomMenuItem(menuId: 2, savedId: Int(applicationSettings.customNavigationMenuItem2))
        self.setCustomMenuItem(menuId: 3, savedId: Int(applicationSettings.customNavigationMenuItem3))
    }

    private func setCustomMenuItem(menuId: Int, savedId: Int) {
        if let selectedCustomMenuItem = self.selectedCustomMenuItems.first(where: { $0.id == menuId }),
           let customMenuItem = self.customMenuItems.first(where: { $0.id == savedId }) {
            selectedCustomMenuItem.title = customMenuItem.title
            selectedCustomMenuItem.viewMode = customMenuItem.viewMode
            selectedCustomMenuItem.image = customMenuItem.image
        }
    }
}
