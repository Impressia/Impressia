//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import WidgetKit
import EnvironmentKit

struct LargeWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        if let uiImage = entry.image, let uiAvatar = entry.avatar {
            self.getWidgetBody(uiImage: Image(uiImage: uiImage), uiAvatar: Image(uiImage: uiAvatar))
        } else {
            self.getWidgetBody(uiImage: Image("Placeholder"), uiAvatar: Image("Avatar"))
                .unredacted()
        }
    }

    @ViewBuilder
    private func getWidgetBody(uiImage: Image, uiAvatar: Image) -> some View {
        VStack {
            Spacer()
            HStack {
                uiAvatar
                    .avatar(size: 24)

                Text(entry.displayName ?? "")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
                    .fontWeight(.semibold)
                    .shadow(color: .black, radius: 2)
                Spacer()
            }
            .padding(.leading, 8)
            .padding(.bottom, 8)
        }
        .background {
            uiImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .widgetURL(URL(string: "\(AppConstants.statusUri)/\(entry.statusId ?? "")"))
        }
    }
}
