//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import WidgetsKit

struct StatusPlaceholderView: View {
    @State var imageHeight: Double
    @State var imageBlurhash: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let imageBlurhash, let uiImage = UIImage(blurHash: imageBlurhash, size: CGSize(width: 32, height: 32)) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width, height: imageHeight)
                } else {
                    Rectangle()
                        .fill(Color.placeholderText)
                        .frame(width: UIScreen.main.bounds.width, height: imageHeight)
                        .redacted(reason: .placeholder)
                }

                VStack(alignment: .leading) {
                    UsernameRow(accountId: "",
                                accountDisplayName: "Verylong Displayname",
                                accountUsername: "@username")

                    Text("Lorem ispum text something")
                        .foregroundColor(.lightGrayColor)
                        .font(.footnote)
                    Text("Lorem ispum text something sdf sdfsdf sdfdsfsdfsdf")
                        .foregroundColor(.lightGrayColor)
                        .font(.footnote)

                    LabelIcon(iconName: "mappin.and.ellipse", value: "Wroclaw, Poland")
                    LabelIcon(iconName: "camera", value: "SONY ILCE-7M3")
                    LabelIcon(iconName: "camera.aperture", value: "Viltrox 24mm F1.8 E")
                    LabelIcon(iconName: "timelapse", value: "24.0 mm, f/1.8, 1/640s, ISO 100")
                    LabelIcon(iconName: "calendar", value: "2 Oct 2022")
                }
                .padding(8)
                .redacted(reason: .placeholder)
                .animatePlaceholder(isLoading: .constant(true))
            }
        }
    }
}
