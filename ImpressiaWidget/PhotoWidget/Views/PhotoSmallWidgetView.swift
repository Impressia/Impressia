//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import WidgetKit
import EnvironmentKit

struct PhotoSmallWidgetView: View {
    var entry: PhotoProvider.Entry

    var body: some View {
        if let uiImage = entry.image {
            self.getWidgetBody(uiImage: Image(uiImage: uiImage), uiAvatarImage: entry.avatar)
        } else {
            self.getWidgetBody(uiImage: Image("Placeholder"), uiAvatarImage: UIImage(named: "Avatar"))
                .unredacted()
        }
    }

    @ViewBuilder
    private func getWidgetBody(uiImage: Image, uiAvatarImage: UIImage?) -> some View {
        VStack {
            Spacer()
            HStack {
                if let uiAvatar = uiAvatarImage {
                    Image(uiImage: uiAvatar)
                        .avatar(size: 16)
                }

                Spacer()
            }
            .padding(.leading, 8)
            .padding(.bottom, 8)
        }
        .widgetBackground {
            uiImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .widgetURL(URL(string: "\(AppConstants.statusUri)/\(entry.statusId ?? "")"))
        }
    }
}
