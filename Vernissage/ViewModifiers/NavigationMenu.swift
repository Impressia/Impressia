//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import EnvironmentKit
import ServicesKit

public extension View {
    func navigationMenu<MenuItems>(menuPosition: Binding<MenuPosition>,
                                   @ViewBuilder menuItems: @escaping () -> MenuItems) -> some View where MenuItems: View {
        modifier(NavigationMenu(menuPosition: menuPosition, menuItems: menuItems))
    }
}

private struct NavigationMenu<MenuItems>: ViewModifier where MenuItems: View {
    @EnvironmentObject var routerPath: RouterPath

    private let menuItems: () -> MenuItems
    @Binding var menuPosition: MenuPosition

    init(menuPosition: Binding<MenuPosition>, @ViewBuilder menuItems: @escaping () -> MenuItems) {
        self.menuItems = menuItems
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
                    HStack {
                        if self.menuPosition == .bottomRight {
                            Spacer()

                            self.menuContainerView()
                                .padding(.trailing, 30)
                                .padding(.bottom, 10)
                        }

                        if self.menuPosition == .bottomLeft {
                            self.menuContainerView()
                                .padding(.leading, 30)
                                .padding(.bottom, 10)

                            Spacer()
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func menuContainerView() -> some View {
        HStack(alignment: .center) {
            if self.menuPosition == .bottomRight {
                self.contextMenuView()
                self.composeImageView()
            }

            if self.menuPosition == .bottomLeft {
                self.composeImageView()
                self.contextMenuView()
            }
        }
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    @ViewBuilder
    private func contextMenuView() -> some View {
        Menu {
            self.menuItems()
        } label: {
            Image(systemName: "line.3.horizontal")
                .resizable()
                .foregroundColor(.mainTextColor.opacity(0.8))
                .shadow(radius: 5)
                .padding(12)
                .frame(width: 44, height: 44)
        }
    }

    private func composeImageView() -> some View {
        Button {
            HapticService.shared.fireHaptic(of: .buttonPress)
            self.routerPath.presentedSheet = .newStatusEditor
        } label: {
            Image(systemName: "plus")
                .resizable()
                .foregroundColor(.mainTextColor.opacity(0.8))
                .shadow(radius: 5)
                .padding(12)
                .frame(width: 44, height: 44)
        }
    }
}
