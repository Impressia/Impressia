//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import NukeUI
import ClientKit
import ServicesKit
import EnvironmentKit

public extension View {
    func imageFavourite(isFavourited: Binding<Bool>) -> some View {
        modifier(ImageFavourite(isFavourited: isFavourited))
    }
}

private struct ImageFavourite: ViewModifier {
    @EnvironmentObject var applicationState: ApplicationState
    @Binding private var isFavourited: Bool

    init(isFavourited: Binding<Bool>) {
        self._isFavourited = isFavourited
    }

    func body(content: Content) -> some View {
        if self.applicationState.showFavouritesOnTimeline && self.isFavourited {
            ZStack {
                // Image.
                content

                // Avatar.
                VStack(alignment: .leading) {
                    Spacer()

                    HStack(alignment: .center) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .shadow(color: .black, radius: 4)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    }
                }
                .padding(.leading, 12)
                .padding(.bottom, 14)
            }
        } else {
            content
        }
    }
}
