//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct LabelIcon: View {
    let iconName: String
    let value: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: iconName)
                .frame(width: 30, alignment: .leading)
            Text(value)
                .font(.footnote)
        }
        .padding(.vertical, 2)
    }
}

struct LabelIconView_Previews: PreviewProvider {
    static var previews: some View {
        LabelIcon(iconName: "camera", value: "Sony A7")
    }
}
