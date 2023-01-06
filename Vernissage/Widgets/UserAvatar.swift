//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI

struct UserAvatar: View {
    @State public var accountAvatar: URL?
    @State public var cachedAvatar: UIImage?
    @State public var width = 48.0
    @State public var height = 48.0
    
    var body: some View {
        if let cachedAvatar {
            Image(uiImage: cachedAvatar)
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fit)
                .frame(width: self.width, height: self.height)
        }
        else {
            AsyncImage(url: self.accountAvatar) { image in
                image
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "person.circle")
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.mainTextColor)
            }
            .frame(width: self.width, height: self.height)
        }
    }
}

struct UserAvatar_Previews: PreviewProvider {
    static var previews: some View {
        UserAvatar()
            .previewLayout(.fixed(width: 128, height: 128))
    }
}
