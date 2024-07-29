//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import WidgetKit
import EnvironmentKit

struct QRCodeMediumWidgetView: View {
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
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                uiQRCode
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .widgetURL(URL(string: "\(AppConstants.accountUri)/\(entry.accountId)"))
                    .if(colorScheme == .dark) {
                        $0.padding(4)
                    }

                HStack(alignment: .center) {
                    uiAvatar
                        .avatar(size: 24)

                    VStack(alignment: .leading) {
                        Text(entry.displayName ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(Color.primary)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Text("@\(entry.acct)")
                            .font(.system(size: 12))
                            .foregroundColor(Color.primary.opacity(0.6))
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    Spacer()
                }
                .padding(.leading, 8)
            }

            HStack(alignment: .center, spacing: 0) {
                if let profileUrl = entry.profileUrl {
                    Text(profileUrl.absoluteString)
                        .font(.system(size: 10))
                        .foregroundColor(Color.primary.opacity(0.6))
                }

                Spacer()

                Image("Pixelfed")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
            }
            .padding(.leading, 3)
            .offset(y: -4)
        }
        .widgetBackground {
        }
        .padding([.leading, .trailing, .top], 12)
    }
}
