//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

public extension View {
    func navigationMenu<MenuItems>(menuPosition: Binding<MenuPosition>,
                                   @ViewBuilder menuItems: @escaping () -> MenuItems) -> some View where MenuItems: View {
        modifier(NavigationMenu(menuPosition: menuPosition, menuItems: menuItems))
    }
}

private struct NavigationMenu<MenuItems>: ViewModifier where MenuItems: View {

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

                            self.menuContent()
                                .padding(.trailing, 20)
                        }

                        if self.menuPosition == .bottomLeft {
                            self.menuContent()
                                .padding(.leading, 20)

                            Spacer()
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func menuContent() -> some View {
        Menu {
            self.menuItems()
        } label: {

            Image(systemName: "line.3.horizontal")
                .resizable()
                .foregroundColor(.mainTextColor.opacity(0.8))
                .shadow(radius: 5)
                .padding(12)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())

        }
    }
}
