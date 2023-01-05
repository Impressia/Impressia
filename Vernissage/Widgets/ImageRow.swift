//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ImageRow: View {
    @State public var attachments: [AttachmentData]
    
    var body: some View {
        if let attachmenData = attachments.first,
           let uiImage = UIImage(data: attachmenData.data) {
            
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                if let count = attachments.count, count > 1 {
                    BottomRight {
                        Text("1 / \(count)")
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .font(.caption2)
                            .foregroundColor(.black)
                            .background(.ultraThinMaterial, in: Capsule())
                    }.padding()
                }
            }
        }
    }
}

struct ImageRow_Previews: PreviewProvider {
    static var previews: some View {
        ImageRow(attachments: [])
    }
}
