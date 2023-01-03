//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct BottomRight<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment:.trailing) {
            Spacer()
            HStack {
                Spacer()
                content
            }
        }
    }
}

struct BottomRight_Previews: PreviewProvider {
    static var previews: some View {
        BottomRight {
            Text("1/2")
        }
    }
}
