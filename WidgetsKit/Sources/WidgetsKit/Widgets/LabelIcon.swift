//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

public struct LabelIcon: View {
    let iconName: String
    let value: String?
    let isExpandable: Bool

    public init(iconName: String, value: String?, isExpandable: Bool = false) {
        self.iconName = iconName
        self.value = value
        self.isExpandable = isExpandable
    }

    public var body: some View {
        if let value, value.isEmpty == false {
            HStack(alignment: .center) {
                Image(systemName: iconName)
                    .frame(width: 24, alignment: .center)

                if self.isExpandable {
                    ExpandableText(text: value, lineLimit: 3)
                        .font(.footnote)
                } else {
                    Text(value)
                        .font(.footnote)
                }
            }
            .padding(.vertical, 2)
        } else {
            EmptyView()
        }
    }
}

struct LabelIconView_Previews: PreviewProvider {
    static var previews: some View {
        LabelIcon(iconName: "camera", value: "Sony A7")
    }
}
