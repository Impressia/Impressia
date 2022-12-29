//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI

struct DismissButtonView: View {
    var action: () -> ()

    public init(_ action: @escaping () -> ()) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray)
                .frame(width: 50, height: 5)
        }
    }
}

struct DismissButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DismissButtonView { }
    }
}
