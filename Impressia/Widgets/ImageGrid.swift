//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import NukeUI
import EnvironmentKit
import WidgetsKit

struct ImageGrid: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(RouterPath.self) var routerPath

    var photoUrl: PhotoUrl
    @Binding var maxHeight: Double
    
    init(photoUrl: PhotoUrl, maxHeight: Binding<Double>) {
        self.photoUrl = photoUrl
        self._maxHeight = maxHeight
    }

    var body: some View {
        if self.photoUrl.sensitive && !self.applicationState.showSensitive {
            BlurredImage(blurhash: self.photoUrl.blurhash)
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture {
                    if let statusId = self.photoUrl.statusId {
                        self.routerPath.navigate(to: .status(id: statusId))
                    }
                }
        } else if let url = photoUrl.url {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: self.maxHeight, height: self.maxHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .clipped()
                        .onTapGesture {
                            if let statusId = self.photoUrl.statusId {
                                self.routerPath.navigate(to: .status(id: statusId))
                            }
                        }
                } else if state.isLoading {
                    self.placeholder()
                } else {
                    self.placeholder()
                }
            }
            .priority(.high)
        } else {
            self.placeholder()
        }
    }

    @ViewBuilder
    private func placeholder() -> some View {
        Image("ImagePlaceholder")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
