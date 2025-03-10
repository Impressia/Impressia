//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

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
        }
    }
}
