//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import WidgetKit
import EnvironmentKit

struct QRCodeSmallWidgetView: View {
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
            uiQRCode
                .resizable()
                .interpolation(.none)
                .widgetURL(URL(string: "\(AppConstants.accountUri)/\(entry.accountId)"))
                .if(colorScheme == .dark) {
                    $0.padding(4)
                }

            HStack {
                uiAvatar
                    .avatar(size: 16)
                    .padding(.leading, 6)

                Spacer()

                Image("Pixelfed")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
            }
        }
        .widgetBackground {
        }
        .padding(8)
    }
}
