//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

extension View {
//    func widgetBackground(backgroundView: some View) -> some View {
//        if #available(iOSApplicationExtension 17.0, *) {
//            return containerBackground(for: .widget) {
//                backgroundView
//            }
//        } else {
//            return background(backgroundView)
//        }
//    }

    func widgetBackground<V>(@ViewBuilder content: @escaping () -> V) -> some View where V: View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                content()
            }
        } else {
            return background(content())
        }
    }
}
