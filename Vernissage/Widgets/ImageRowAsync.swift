//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonSwift
import NukeUI

struct ImageRowAsync: View {
    @State public var attachments: [Attachment]
    @State private var imageHeight = UIScreen.main.bounds.width
    
    var body: some View {
        if let attachment = attachments.first {
            ZStack {
                LazyImage(url: attachment.url, resizingMode: .fill)
                    .onSuccess({ imageResponse in
                        let imgHeight = imageResponse.image.size.height
                        let imgWidth = imageResponse.image.size.width

                        let divider = imgWidth / UIScreen.main.bounds.size.width
                        self.imageHeight = imgHeight / divider
                    })
                    .frame(height: self.imageHeight <= 0 ? UIScreen.main.bounds.width : self.imageHeight)
                    
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

struct ImageRowAsync_Previews: PreviewProvider {
    static var previews: some View {
        ImageRow(attachments: [])
    }
}
