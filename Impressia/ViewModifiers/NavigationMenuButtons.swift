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
                               viewMode: Binding<MainView.ViewMode>,
                               onViewModeIconTap: @escaping (MainView.ViewMode) -> Void) -> some View {
        modifier(NavigationMenuButtons(menuPosition: menuPosition,
                                       viewMode: viewMode,
                                       onViewModeIconTap: onViewModeIconTap))
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

    @State private var displayedCustomMenuItems = [
        SelectedMenuItemDetails(position: 1, viewMode: .home),
        SelectedMenuItemDetails(position: 2, viewMode: .local),
        SelectedMenuItemDetails(position: 3, viewMode: .profile)
    ]

    @State private var hiddenMenuItems: [MainView.ViewMode] = []

    @Binding var menuPosition: MenuPosition
    @Binding var viewMode: MainView.ViewMode

    init(menuPosition: Binding<MenuPosition>, viewMode: Binding<MainView.ViewMode>, onViewModeIconTap: @escaping (MainView.ViewMode) -> Void) {
        self.onViewModeIconTap = onViewModeIconTap
        self._menuPosition = menuPosition
        self._viewMode = viewMode
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
                        Spacer()
                        self.menuContainerView()
                            .padding(.bottom, 10)
                        Spacer()
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
                AccountAvatarMenu(menuPosition: $menuPosition, viewMode: $viewMode)

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

                AccountAvatarMenu(menuPosition: $menuPosition, viewMode: $viewMode)
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
        .environment(\.menuOrder, .fixed)
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
            MainNavigationOptions(hiddenMenuItems: Binding.constant([])) { viewMode in
                withAnimation {
                    displayedCustomMenuItem.viewMode = viewMode
                }

                // Saving in database.
                switch displayedCustomMenuItem.position {
                case 1:
                    ApplicationSettingsHandler.shared.set(customNavigationMenuItem1: viewMode.rawValue, modelContext: modelContext)
                case 2:
                    ApplicationSettingsHandler.shared.set(customNavigationMenuItem2: viewMode.rawValue, modelContext: modelContext)
                case 3:
                    ApplicationSettingsHandler.shared.set(customNavigationMenuItem3: viewMode.rawValue, modelContext: modelContext)
                default:
                    break
                }

                self.hiddenMenuItems = self.displayedCustomMenuItems.map({ $0.viewMode })
                MenuCustomizableTip().invalidate(reason: .actionPerformed)
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
        if let displayedCustomMenuItem = self.displayedCustomMenuItems.first(where: { $0.position == position }) {
            displayedCustomMenuItem.viewMode = viewMode
        }
    }
}
