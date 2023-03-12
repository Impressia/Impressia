//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
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
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            .frame(width: 24, height: 24)
                    )
                    .shadow(radius: 4)

                Text(entry.displayName ?? "")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .shadow(radius: 8)
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

