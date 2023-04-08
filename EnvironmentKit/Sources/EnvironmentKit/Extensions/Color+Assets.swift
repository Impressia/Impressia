//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

public extension Color {

    // MARK: - Text Colors
    static let dangerColor = Color("DangerColor")
    static let lightGrayColor = Color("LightGrayColor")
    static let mainTextColor = Color("MainTextColor")
    static let selectedRowColor = Color("SelectedRowColor")
    static let viewBackgroundColor = Color("ViewBackgroundColor")
    static let keyboardToolbarColor = Color("KeyboardToolbar")
    static let viewTextColor = Color("ViewTextColor")
    static let accentColor1 = Color("AccentColor1")
    static let accentColor2 = Color("AccentColor2")
    static let accentColor3 = Color("AccentColor3")
    static let accentColor4 = Color("AccentColor4")
    static let accentColor5 = Color("AccentColor5")
    static let accentColor6 = Color("AccentColor6")
    static let accentColor7 = Color("AccentColor7")
    static let accentColor8 = Color("AccentColor8")
    static let accentColor9 = Color("AccentColor9")
    static let accentColor10 = Color("AccentColor10")
}

public extension Color {
    func toUIColor() -> UIColor {
        UIColor(self)
    }
}
