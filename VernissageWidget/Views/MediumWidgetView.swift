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
            VStack {
                Spacer()
                HStack {
                    Image(uiImage: uiAvatar)
                        .resizable()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)

                    Text(entry.displayName ?? "")
                    Spacer()
                }
                .padding(.leading, 8)
                .padding(.bottom, 8)
            }
            .background {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .widgetURL(URL(string: "\(AppConstants.statusUri)/\(entry.statusId ?? "")"))
            }
        } else {
            VStack {
                Spacer()
                HStack {
                    Circle()
                        .foregroundColor(Color(UIColor.placeholderText))
                        .frame(width: 32, height: 32)

                    Text(entry.displayName ?? "")
                    Spacer()
                }
            }
            .padding(.leading, 8)
            .padding(.bottom, 8)
        }
    }
}

