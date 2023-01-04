//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct UsernameRow: View {
    @ObservedObject public var statusData: StatusData

    var body: some View {
        HStack (alignment: .center) {
            AsyncImage(url: statusData.accountAvatar) { image in
                image
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "person.circle")
                    .resizable()
                    .foregroundColor(Color("MainTextColor"))
            }
            .frame(width: 48.0, height: 48.0)
            
            VStack (alignment: .leading) {
                Text(statusData.accountDisplayName ?? statusData.accountUsername)
                    .foregroundColor(Color("DisplayNameColor"))
                Text("@\(statusData.accountUsername)")
                    .foregroundColor(Color("LightGrayColor"))
                    .font(.footnote)
            }
            .padding(.leading, 8)
        }
    }
}

struct UsernameRow_Previews: PreviewProvider {
    static var previews: some View {
        UsernameRow(statusData: StatusData())
    }
}
