//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

struct UserProfilePrivateAccountView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("userProfile.title.privateProfileTitle", comment: "This profile is private.")
                .fontWeight(.bold)
                .font(.headline)
            Text("userProfile.title.privateProfileSubtitle", comment: "Only approved followers can see photos.")
                .fontWeight(.light)
                .font(.subheadline)
            Spacer()
        }.padding(.top, 60)
    }
}
