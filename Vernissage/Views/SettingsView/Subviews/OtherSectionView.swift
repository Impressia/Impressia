//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct OtherSectionView: View {
    var body: some View {
        Section("settings.title.other") {
            NavigationLink(value: RouteurDestinations.thirdParty) {
                Text("settings.title.thirdParty", comment: "Third party")
            }
            
            HStack {
                Text("settings.title.reportBug", comment: "Report a bug")
                Spacer()
                Link(NSLocalizedString("settings.title.githubIssues", comment: "Issues on GitHub"), destination: URL(string: "https://github.com/VernissageApp/Home/issues")!)
                    .font(.footnote)
            }
            
            HStack {
                Text("settings.title.follow", comment: "Follow me on Mastodon")
                Spacer()
                Link("@mczachurski", destination: URL(string: "https://mastodon.social/@mczachurski")!)
                    .font(.footnote)
            }
        }
    }
}
