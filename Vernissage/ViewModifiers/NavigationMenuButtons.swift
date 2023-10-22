//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import EnvironmentKit
import ServicesKit
import TipKit
import WidgetsKit

@MainActor
extension View {
    func navigationMenuButtons(menuPosition: Binding<MenuPosition>,
                               onViewModeIconTap: @escaping (MainView.ViewMode) -> Void) -> some View {
        modifier(NavigationMenuButtons(menuPosition: menuPosition, onViewModeIconTap: onViewModeIconTap))
    }
}

@MainActor
private struct NavigationMenuButtons: ViewModifier {
    @Environment(ApplicationState.self) var applicationState
    @Environment(RouterPath.self) var routerPath
    @Environment(\.modelContext) private var modelContext

    private let menuCustomizableTip = MenuCustomizableTip()
    private let onViewModeIconTap: (MainView.ViewMode) -> Void
    private let imageFontSize = 20.0

    private let customMenuItems: [MainView.ViewMode] = [
        .home,
        .local,
        .federated,
        .search,
        .profile,
        .notifications
    ]

    @State private var displayedCustomMenuItems = [
        SelectedMenuItemDetails(position: 1, viewMode: .home),
        SelectedMenuItemDetails(position: 2, viewMode: .local),
        SelectedMenuItemDetails(position: 3, viewMode: .profile)
    ]

    @State private var hiddenMenuItems: [MainView.ViewMode] = []

    @Binding var menuPosition: MenuPosition

    init(menuPosition: Binding<MenuPosition>, onViewModeIconTap: @escaping (MainView.ViewMode) -> Void) {
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
            .popoverTip(menuCustomizableTip, arrowEdge: .bottom)
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
            .popoverTip(menuCustomizableTip, arrowEdge: .bottom)
        }
    }

    @ViewBuilder
    private func contextMenuView() -> some View {
        Menu {
            MainNavigationOptions(hiddenMenuItems: $hiddenMenuItems) { viewMode in
                self.onViewModeIconTap(viewMode)
            }
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
        ForEach(self.displayedCustomMenuItems) { item in
            self.customMenuItemView(item)
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
    private func customMenuItemView(_ displayedCustomMenuItem: SelectedMenuItemDetails) -> some View {
        Button {
            self.onViewModeIconTap(displayedCustomMenuItem.viewMode)
        } label: {
            displayedCustomMenuItem.viewMode.getImage(applicationState: applicationState)
                .font(.system(size: self.imageFontSize))
                .foregroundColor(.mainTextColor.opacity(0.75))
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
        }.contextMenu {
            self.listOfIconsView(displayedCustomMenuItem)
        }
    }

    @ViewBuilder
    private func listOfIconsView(_ displayedCustomMenuItem: SelectedMenuItemDetails) -> some View {
        ForEach(self.customMenuItems) { item in
            Button {
                withAnimation {
                    displayedCustomMenuItem.viewMode = item
                }

                // Saving in database.
                switch displayedCustomMenuItem.position {
                case 1:
                    ApplicationSettingsHandler.shared.set(customNavigationMenuItem1: item.rawValue, modelContext: modelContext)
                case 2:
                    ApplicationSettingsHandler.shared.set(customNavigationMenuItem2: item.rawValue, modelContext: modelContext)
                case 3:
                    ApplicationSettingsHandler.shared.set(customNavigationMenuItem3: item.rawValue, modelContext: modelContext)
                default:
                    break
                }

                self.hiddenMenuItems = self.displayedCustomMenuItems.map({ $0.viewMode })
                MenuCustomizableTip().invalidate(reason: .actionPerformed)
            } label: {
                Label {
                    Text(item.title, comment: "Menu item")
                } icon: {
                    item.getImage(applicationState: applicationState)
                }
            }
        }
    }

    private func loadCustomMenuItems() {
        let applicationSettings = ApplicationSettingsHandler.shared.get(modelContext: modelContext)

        self.setCustomMenuItem(position: 1, viewMode: MainView.ViewMode(rawValue: Int(applicationSettings.customNavigationMenuItem1)) ?? .home)
        self.setCustomMenuItem(position: 2, viewMode: MainView.ViewMode(rawValue: Int(applicationSettings.customNavigationMenuItem2)) ?? .local)
        self.setCustomMenuItem(position: 3, viewMode: MainView.ViewMode(rawValue: Int(applicationSettings.customNavigationMenuItem3)) ?? .profile)

        self.hiddenMenuItems = self.displayedCustomMenuItems.map({ $0.viewMode })
    }

    private func setCustomMenuItem(position: Int, viewMode: MainView.ViewMode) {
        if let displayedCustomMenuItem = self.displayedCustomMenuItems.first(where: { $0.position == position }),
           let customMenuItem = self.customMenuItems.first(where: { $0 == viewMode }) {
            displayedCustomMenuItem.viewMode = customMenuItem
        }
    }
}
