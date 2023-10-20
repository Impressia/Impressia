//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import EnvironmentKit

public struct ImageFavourite: View {
    @Environment(ApplicationState.self) var applicationState
    @Binding private var isFavourited: Bool

    public init(isFavourited: Binding<Bool>) {
        self._isFavourited = isFavourited
    }

    public var body: some View {
        if self.applicationState.showFavouritesOnTimeline && self.isFavourited {
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
    }
}
