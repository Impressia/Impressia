//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

public extension View {
    func asyncAfter(_ time: Double, operation: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            operation()
        }
    }
}

public extension ViewModifier {
    func asyncAfter(_ time: Double, operation: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            operation()
        }
    }
}
