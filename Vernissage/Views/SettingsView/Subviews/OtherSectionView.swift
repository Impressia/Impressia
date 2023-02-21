//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct OtherSectionView: View {
    var body: some View {
        Section("Other") {
            NavigationLink(value: RouteurDestinations.thirdParty) {
                Text("Third party")
            }
            
            HStack {
                Text("Report a bug")
                Spacer()
                Link("Issues on Github", destination: URL(string: "https://github.com/VernissageApp/Home/issues")!)
                    .font(.footnote)
            }
            
            HStack {
                Text("Follow me on Mastodon")
                Spacer()
                Link("@mczachurski", destination: URL(string: "https://mastodon.social/@mczachurski")!)
                    .font(.footnote)
            }
        }
    }
}
