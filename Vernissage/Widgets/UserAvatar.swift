//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import NukeUI

struct UserAvatar: View {
    @EnvironmentObject var applicationState: ApplicationState
    
    public enum Size {
        case mini, list, comment, profile
      
        public var size: CGSize {
            switch self {
            case .mini:
                return .init(width: 20, height: 20)
            case .comment:
                return .init(width: 32, height: 32)
            case .list:
                return .init(width: 48, height: 48)
            case .profile:
                return .init(width: 96, height: 96)
            }
        }
    }
    
    public let accountAvatar: URL?
    public let size: Size
    
    public init(accountAvatar: URL?, size: Size = .list) {
      self.accountAvatar = accountAvatar
      self.size = size
    }
    
    var body: some View {
        if let accountAvatar {
            if let cachedAvatar = CacheImageService.shared.get(for: accountAvatar) {
                cachedAvatar
                    .resizable()
                    .clipShape(applicationState.avatarShape.shape())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.size.width, height: size.size.height)
            } else {
                LazyImage(url: accountAvatar) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(applicationState.avatarShape.shape())
                    } else if state.isLoading {
                        placeholderView
                    } else {
                        placeholderView
                    }
                }
                .priority(.high)
                .task {
                    await CacheImageService.shared.download(url: accountAvatar)
                }
                .frame(width: size.size.width, height: size.size.height)
            }
        } else {
            placeholderView
                .frame(width: size.size.width, height: size.size.height)
        }
    }
    
    @ViewBuilder private var placeholderView: some View {
        Image("Avatar")
            .resizable()
            .clipShape(applicationState.avatarShape.shape())
            .aspectRatio(contentMode: .fit)
    }
}

