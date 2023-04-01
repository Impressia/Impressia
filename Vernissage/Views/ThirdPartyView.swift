//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

struct ThirdPartyView: View {
    var body: some View {
        List {
            Section("Lazy image & cache") {
                VStack(alignment: .leading) {
                    Link("https://github.com/kean/Nuke",
                         destination: URL(string: "https://github.com/kean/Nuke")!)
                    .padding(.bottom, 4)
                    Text("Nuke provides an efficient way to download and display images in your app. It's easy to learn and use. Its architecture enables many powerful features while offering virtually unlimited possibilities for customization.")
                }
                .font(.footnote)
            }
            
            Section("Custom emoji") {
                VStack(alignment: .leading)  {
                    Link("https://github.com/divadretlaw/EmojiText",
                         destination: URL(string: "https://github.com/divadretlaw/EmojiText")!)
                    .padding(.bottom, 4)
                    Text("Render Custom Emoji in Text. Supports local and remote emojis. Remote emojis are loadad and cached using Nuke.")
                }
                .font(.footnote)
            }

            Section("Status body") {
                VStack(alignment: .leading)  {
                    Link("https://gitlab.com/mflint/HTML2Markdown",
                         destination: URL(string: "https://gitlab.com/mflint/HTML2Markdown")!)
                    .padding(.bottom, 4)
                    Text("It's a Swift Package which attempts to convert HTML into Markdown.")
                }
                .font(.footnote)
            }
            
            Section("OAuth authrisation") {
                VStack(alignment: .leading)  {
                    Link("https://github.com/OAuthSwift/OAuthSwift",
                         destination: URL(string: "https://github.com/OAuthSwift/OAuthSwift")!)
                    .padding(.bottom, 4)
                    Text("Swift based OAuth library for iOS and macOS.")
                }
                .font(.footnote)
            }
            
            Section("Notifications") {
                VStack(alignment: .leading)  {
                    Link("https://github.com/omaralbeik/Drops",
                         destination: URL(string: "https://github.com/omaralbeik/Drops")!)
                    .padding(.bottom, 4)
                    Text("A µFramework for showing alerts like the one used when copying from pasteboard or connecting Apple pencil.")
                }
                .font(.footnote)
            }
            
            Section("Loaders") {
                VStack(alignment: .leading)  {
                    Link("https://github.com/exyte/ActivityIndicatorView",
                         destination: URL(string: "https://github.com/exyte/ActivityIndicatorView")!)
                    .padding(.bottom, 4)
                    Text("A number of preset loading indicators created with SwiftUI.")
                }
                .font(.footnote)
            }
            
            Section("HTML String") {
                VStack(alignment: .leading)  {
                    Link("https://github.com/alexisakers/HTMLString",
                         destination: URL(string: "https://github.com/alexisakers/HTMLString")!)
                    .padding(.bottom, 4)
                    Text("HTMLString is a library written in Swift that allows your program to add and remove HTML entities in Strings.")
                }
                .font(.footnote)
            }
            
            Section("Fleur De Leah") {
                VStack(alignment: .leading)  {
                    Link("https://fonts.google.com/specimen/Fleur+De+Leah",
                         destination: URL(string: "https://fonts.google.com/specimen/Fleur+De+Leah")!)
                    .padding(.bottom, 4)
                    Text("Font used in the application in the icons and in the splash screen.")
                }
                .font(.footnote)
            }
        }
        .navigationTitle("thirdParty.navigationBar.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

