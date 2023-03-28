//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

struct OtherSectionView: View {
    var body: some View {
        Section("settings.title.other") {
            NavigationLink(value: RouteurDestinations.thirdParty) {
                Text("settings.title.thirdParty", comment: "Third party")
            }

            HStack {
                Text("settings.title.privacyPolicy", comment: "Privacy policy")
                Spacer()
                Link(NSLocalizedString("settings.title.openPage", comment: "Open"), destination: URL(string: "https://mczachurski.dev/vernissage/privacy-policy.html")!)
                    .font(.footnote)
            }
            
            HStack {
                Text("settings.title.terms", comment: "Terms & Conditions")
                Spacer()
                Link(NSLocalizedString("settings.title.openPage", comment: "Open"), destination: URL(string: "https://mczachurski.dev/vernissage/terms.html")!)
                    .font(.footnote)
            }
            
            HStack {
                Text("settings.title.reportBug", comment: "Report a bug")
                Spacer()
                Link(NSLocalizedString("settings.title.githubIssues", comment: "Issues on GitHub"), destination: URL(string: "https://github.com/VernissageApp/Home/issues")!)
                    .font(.footnote)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("settings.title.followVernissage", comment: "Follow Vernissage")
                    Text("Mastodon account")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
                
                Spacer()
                Link("@vernissage", destination: URL(string: "https://mastodon.social/@vernissage")!)
                    .font(.footnote)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("settings.title.follow", comment: "Follow me")
                    Text("settings.title.mastodonAccount", comment: "Mastodon account")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
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
                        .foregroundColor(.lightGrayColor)
                }
                
                Spacer()
                Link("@mczachurski", destination: URL(string: "https://pixelfed.social/@mczachurski")!)
                    .font(.footnote)
            }
        }
    }
}
