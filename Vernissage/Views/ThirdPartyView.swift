//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

@MainActor
struct ThirdPartyView: View {
    var body: some View {
        List {
            Section("thirdparty.lazyimage.title") {
                VStack(alignment: .leading) {
                    Link("thirdparty.lazyimage.address",
                         destination: URL(string: "https://github.com/kean/Nuke")!)
                    .padding(.bottom, 4)

                    Text("thirdparty.lazyimage.description", comment: "Lazy image section description.")
                }
                .font(.footnote)
            }

            Section("thirdparty.customemoji.title") {
                VStack(alignment: .leading) {
                    Link("thirdparty.customemoji.address",
                         destination: URL(string: "https://github.com/divadretlaw/EmojiText")!)
                    .padding(.bottom, 4)
                    Text("thirdparty.customemoji.description", comment: "Render Custom Emoji in Text. Supports local and remote emojis. Remote emojis are loadad and cached using Nuke.")
                }
                .font(.footnote)
            }

            Section("thirdparty.htmlmarkdown.title") {
                VStack(alignment: .leading) {
                    Link("thirdparty.htmlmarkdown.address",
                         destination: URL(string: "https://gitlab.com/mflint/HTML2Markdown")!)
                    .padding(.bottom, 4)
                    Text("thirdparty.htmlmarkdown.description", comment: "It's a Swift Package which attempts to convert HTML into Markdown.")
                }
                .font(.footnote)
            }

            Section("thirdparty.oauth.title") {
                VStack(alignment: .leading) {
                    Link("thirdparty.oauth.address",
                         destination: URL(string: "https://github.com/OAuthSwift/OAuthSwift")!)
                    .padding(.bottom, 4)
                    Text("thirdparty.oauth.description", comment: "Swift based OAuth library for iOS and macOS.")
                }
                .font(.footnote)
            }

            Section("thirdparty.notifications.title") {
                VStack(alignment: .leading) {
                    Link("thirdparty.notifications.address",
                         destination: URL(string: "https://github.com/omaralbeik/Drops")!)
                    .padding(.bottom, 4)
                    Text("thirdparty.notifications.description", comment: "A µFramework for showing alerts like the one used when copying from pasteboard or connecting Apple pencil.")
                }
                .font(.footnote)
            }

            Section("thirdparty.loaders.title") {
                VStack(alignment: .leading) {
                    Link("thirdparty.loaders.address",
                         destination: URL(string: "https://github.com/exyte/ActivityIndicatorView")!)
                    .padding(.bottom, 4)
                    Text("thirdparty.loaders.description", comment: "A number of preset loading indicators created with SwiftUI.")
                }
                .font(.footnote)
            }

            Section("thirdparty.htmlstring.title") {
                VStack(alignment: .leading) {
                    Link("thirdparty.htmlstring.address",
                         destination: URL(string: "https://github.com/alexisakers/HTMLString")!)
                    .padding(.bottom, 4)
                    Text("thirdparty.htmlstring.description", comment: "HTMLString is a library written in Swift that allows your program to add and remove HTML entities in Strings.")
                }
                .font(.footnote)
            }

            Section("thirdparty.fleur.title") {
                VStack(alignment: .leading) {
                    Link("thirdparty.fleur.address",
                         destination: URL(string: "https://fonts.google.com/specimen/Fleur+De+Leah")!)
                    .padding(.bottom, 4)
                    Text("thirdparty.fleur.description", comment: "Font used in the application in the icons and in the splash screen.")
                }
                .font(.footnote)
            }

            Section("thirdparty.qrcodes.title") {
                VStack(alignment: .leading) {
                    Link("thirdparty.qrcodes.address",
                         destination: URL(string: "https://github.com/dmrschmidt/QRCode")!)
                    .padding(.bottom, 4)
                    Text("thirdparty.qrcodes.description", comment: "A simple QR code image generator to use in your apps, written in Swift 5.")
                }
                .font(.footnote)
            }
        }
        .navigationTitle("thirdParty.navigationBar.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
