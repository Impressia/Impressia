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
                Label("settings.title.thirdParty", systemImage: "shippingbox")
            }

            Link(destination: URL(string: "https://mczachurski.dev/vernissage/privacy-policy.html")!) {
                Label("settings.title.privacyPolicy", systemImage: "hand.raised.square")
            }
            .tint(.mainTextColor)

            Link(destination: URL(string: "https://mczachurski.dev/vernissage/terms.html")!) {
                Label("settings.title.terms", systemImage: "doc.text")
            }
            .tint(.mainTextColor)

            Link(destination: URL(string: "https://apps.apple.com/app/id1663543216?action=write-review")!) {
                Label("settings.title.rate", systemImage: "star")
            }
            .tint(.mainTextColor)

            Link(destination: URL(string: "https://github.com/VernissageApp/Vernissage")!) {
                Label("settings.title.sourceCode", systemImage: "swift")
            }
            .tint(.mainTextColor)

            Link(destination: URL(string: "https://github.com/VernissageApp/Vernissage/issues")!) {
                Label("settings.title.reportBug", systemImage: "ant")
            }
            .tint(.mainTextColor)
        }
    }
}
