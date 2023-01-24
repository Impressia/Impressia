//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct UserAvatar: View {
    @EnvironmentObject var applicationState: ApplicationState
    
    @State public var accountId: String
    @State public var accountAvatar: URL?
    @State public var width = 48.0
    @State public var height = 48.0
    
    var body: some View {
        if let cachedAvatar = CacheAvatarService.shared.getImage(for: accountId) {
            cachedAvatar
                .resizable()
                .clipShape(applicationState.avatarShape.shape())
                .aspectRatio(contentMode: .fit)
                .frame(width: self.width, height: self.height)
        }
        else {
            AsyncImage(url: self.accountAvatar) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .clipShape(applicationState.avatarShape.shape())
                        .aspectRatio(contentMode: .fit)
                        .onAppear {
                            CacheAvatarService.shared.addImage(for: self.accountId, image: image)
                        }
                } else if phase.error != nil {
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.lightGrayColor)
                        .clipShape(AvatarShape.circle.shape())
                        .background(
                            AvatarShape.circle.shape()
                        )
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.lightGrayColor)
                        .clipShape(applicationState.avatarShape.shape())
                        .background(
                            AvatarShape.circle.shape()
                        )
                }
            }
            .frame(width: self.width, height: self.height)
        }
    }
}

