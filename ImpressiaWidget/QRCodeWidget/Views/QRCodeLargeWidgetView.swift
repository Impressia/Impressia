//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import WidgetKit
import EnvironmentKit

struct QRCodeLargeWidgetView: View {
    @Environment(\.colorScheme) var colorScheme

    var entry: QRCodeProvider.Entry

    private let qrCodeImage: UIImage?

    init(entry: QRCodeProvider.Entry) {
        self.entry = entry

        if let profileUrl = entry.profileUrl {
            self.qrCodeImage = QRCodeGenerator.shared.generateQRCode(from: profileUrl.absoluteString)

        } else {
            self.qrCodeImage = QRCodeGenerator.shared.generateQRCode(from: "https://pixelfed.org")
        }
    }

    var body: some View {
        if let uiAvatar = entry.avatar, let qrCodeImage {
            self.getWidgetBody(uiAvatar: Image(uiImage: uiAvatar), uiQRCode: Image(uiImage: qrCodeImage))
        } else {
            self.getWidgetBody(uiAvatar: Image("Avatar"), uiQRCode: Image("QRCode"))
                .unredacted()
        }
    }

    @ViewBuilder
    private func getWidgetBody(uiAvatar: Image, uiQRCode: Image) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                uiAvatar
                    .avatar(size: 32)

                Text(entry.displayName ?? "")
                    .font(.system(size: 18))
                    .foregroundColor(Color.primary)
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding(.leading, 6)
            .padding(.bottom, 4)

            uiQRCode
                .resizable()
                .interpolation(.none)
                .widgetURL(URL(string: "\(AppConstants.accountUri)/\(entry.accountId)"))
                .if(colorScheme == .dark) {
                    $0.padding(8)
                }

            if let profileUrl = entry.profileUrl {
                HStack {
                    Text(profileUrl.absoluteString)
                        .font(.system(size: 10))
                        .foregroundColor(Color.primary.opacity(0.6))
                    Spacer()
                }
                .offset(y: -2)
                .padding(.leading, 8)
            }

            HStack {
                Spacer()
                Image("Pixelfed")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32)
                    .offset(y: -8)
            }
        }
        .widgetBackground {
        }
        .padding([.leading, .trailing, .top], 24)
    }
}
