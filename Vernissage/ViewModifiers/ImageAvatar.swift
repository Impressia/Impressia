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
    func imageAvatar(displayName: String?, avatarUrl: URL?) -> some View {
        modifier(ImageAvatar(displayName: displayName, avatarUrl: avatarUrl))
    }
}

private struct ImageAvatar: ViewModifier {
    @EnvironmentObject var applicationState: ApplicationState

    private let displayName: String?
    private let avatarUrl: URL?

    init(displayName: String?, avatarUrl: URL?) {
        self.displayName = displayName
        self.avatarUrl = avatarUrl
    }

    func body(content: Content) -> some View {
        if self.applicationState.showAvatarsOnTimeline {
            ZStack {
                // Image.
                content

                // Avatar.
                VStack(alignment: .leading) {

                    HStack(alignment: .center) {
                        LazyImage(url: avatarUrl) { state in
                            if let image = state.image {
                                self.buildAvatar(image: image)
                            } else if state.isLoading {
                                self.buildAvatar()
                            } else {
                                self.buildAvatar()
                            }
                        }

                        Text(displayName ?? "")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .fontWeight(.semibold)
                            .shadow(color: .black, radius: 2)
                        Spacer()
                    }

                    Spacer()
                }
                .padding(.leading, 6)
                .padding(.top, 6)
            }
        } else {
            content
        }
    }

    @ViewBuilder
    private func buildAvatar(image: Image? = nil) -> some View {
        (image ?? Image("Avatar"))
            .resizable()
            .clipShape(applicationState.avatarShape.shape())
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .overlay(
                applicationState.avatarShape.shape()
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    .frame(width: 24, height: 24)
            )
            .shadow(color: .black, radius: 2)
    }
}
