//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct Tag<Content: View>: View {
    let content: Content
    let action: () -> Void

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.action = action
    }
    
    var body: some View {
        Button {
            self.action()
        } label: {
            content
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color("actionButtonColor"))
                .clipShape(Capsule())
        }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        Tag {
            
        } content: {
            HStack {
                Image(systemName: "arrow.2.squarepath")
                Text("7 boosts")
            }
        }
    }
}
