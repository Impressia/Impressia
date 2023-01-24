//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

public enum TintColor: Int {
    case accentColor1 = 1
    case accentColor2 = 2
    case accentColor3 = 3
    case accentColor4 = 4
    case accentColor5 = 5
    case accentColor6 = 6
    case accentColor7 = 7
    case accentColor8 = 8
    case accentColor9 = 9
    case accentColor10 = 10
    
    public func color() -> Color {
        switch self {
        case .accentColor1:
            return Color.accentColor1
        case .accentColor2:
            return Color.accentColor2
        case .accentColor3:
            return Color.accentColor3
        case .accentColor4:
            return Color.accentColor4
        case .accentColor5:
            return Color.accentColor5
        case .accentColor6:
            return Color.accentColor6
        case .accentColor7:
            return Color.accentColor7
        case .accentColor8:
            return Color.accentColor8
        case .accentColor9:
            return Color.accentColor9
        case .accentColor10:
            return Color.accentColor10
        }
    }
    
    public func uiColor() -> UIColor {
        return self.color().toUIColor()
    }
}
