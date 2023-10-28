//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import NukeUI
import EnvironmentKit

public struct ImageAvatar: View {
    @Environment(ApplicationState.self) var applicationState

    private let displayName: String?
    private let avatarUrl: URL?
    private let rebloggedAccountDisplayName: String?
    private let rebloggedAccountAvatar: URL?
    private let onTap: (Bool) -> Void
    
    public init(displayName: String?, avatarUrl: URL?, rebloggedAccountDisplayName: String?, rebloggedAccountAvatar: URL?, onTap: @escaping (Bool) -> Void) {
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.rebloggedAccountAvatar = rebloggedAccountAvatar
        self.rebloggedAccountDisplayName = rebloggedAccountDisplayName
        self.onTap = onTap
    }

    public var body: some View {
        if self.applicationState.showAvatarsOnTimeline {
            VStack(alignment: .leading, spacing: 0){
                HStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 4) {
                        UserAvatar(accountAvatar: avatarUrl, size: .mini)
                        Text(displayName ?? "")
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .padding(.trailing, 8)
                    }
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .background(.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(.leading, 8)
                    .padding(.top, 8)
                    .onTapGesture {
                        self.onTap(true)
                    }
                    
                    if let rebloggedAccountAvatar = self.rebloggedAccountAvatar,
                       let rebloggedAccountDisplayName = self.rebloggedAccountDisplayName {
                        HStack(alignment: .center, spacing: 4) {
                            UserAvatar(accountAvatar: rebloggedAccountAvatar, size: .mini)
                            Text(rebloggedAccountDisplayName)
                                .lineLimit(1)
                            Image("custom.rocket")
                                .padding(.trailing, 8)
                        }
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .background(.black.opacity(0.6))
                        .clipShape(Capsule())
                        .padding(.leading, 8)
                        .padding(.top, 8)
                        .onTapGesture {
                            self.onTap(false)
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.trailing, 58)
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
