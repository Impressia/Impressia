//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

// MARK: - Socials Section View

struct SocialsSectionView: View {
    var body: some View {
        Section("settings.title.socials") {
            HStack {
                VStack(alignment: .leading) {
                    Text("settings.title.followImpressia", comment: "Follow Impressia")
                    Text("settings.title.mastodonAccount", comment: "Mastodon account")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
                
                Spacer()
                Link("@impressia", destination: URL(string: "https://mastodon.social/@impressia")!)
                    .font(.footnote)
            }
            .modifier(CopyableTextViewModifier(copyable: "@impressia@mastodon.social"))
            .accessibilityElement(children: .combine)
            .accessibilityValue("@impressia")
            .accessibilityRemoveTraits(.isButton)
            .accessibilityAddTraits(.isLink)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("settings.title.follow", comment: "Follow me")
                    Text("settings.title.mastodonAccount", comment: "Mastodon account")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
                
                Spacer()
                Link("@mczachurski", destination: URL(string: "https://mastodon.social/@mczachurski")!)
                    .font(.footnote)
            }
            .modifier(CopyableTextViewModifier(copyable: "@mczachurski@mastodon.social"))
            .accessibilityElement(children: .combine)
            .accessibilityValue("@mczachurski")
            .accessibilityRemoveTraits(.isButton)
            .accessibilityAddTraits(.isLink)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("settings.title.follow", comment: "Follow me")
                    Text("settings.title.pixelfedAccount", comment: "Pixelfed account")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
                
                Spacer()
                Link("@mczachurski", destination: URL(string: "https://pixelfed.social/@mczachurski")!)
                    .font(.footnote)
            }
            .modifier(CopyableTextViewModifier(copyable: "@mczachurski@pixelfed.social"))
            .accessibilityElement(children: .combine)
            .accessibilityValue("@mczachurski")
            .accessibilityRemoveTraits(.isButton)
            .accessibilityAddTraits(.isLink)
        }
    }
}

// MARK: - CopyableTextViewModifier

/// `ViewModifier` to allow the user to copy in its clipboard the given value
/// to then paste it elsewhere. Can be sueful for Fediverse accounts handles.
private struct CopyableTextViewModifier: ViewModifier {

    let copyable: String

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button(action: {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = copyable
                }, label: {
                    Text("global.copyToClipboard")
                    Image(systemName: "doc.on.doc").accessibilityHidden(true)
                })
            }
    }
}

