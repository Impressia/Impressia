//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ImageRow: View {
    @State public var status: StatusData
    
    @State private var imageHeight = UIScreen.main.bounds.width
    @State private var imageWidth = UIScreen.main.bounds.width
    
    var body: some View {
        if let attachmenData = self.status.attachments().first,
           let uiImage = UIImage(data: attachmenData.data) {
            
            ZStack {
                if self.status.sensitive {
                    ContentWarning(blurhash: attachmenData.blurhash, spoilerText: self.status.spoilerText) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .transition(.opacity)
                    }
                } else {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }

                if let count = self.status.attachments().count, count > 1 {
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
            .frame(width: self.imageWidth, height: self.imageHeight)
            .onAppear {
                self.recalculateSizeOfDownloadedImage(uiImage: uiImage)
            }
        }
    }
    
    private func recalculateSizeOfDownloadedImage(uiImage: UIImage) {
        let imgHeight = uiImage.size.height
        let imgWidth = uiImage.size.width
        let calculatedHeight = self.calculateHeight(width: imgWidth, height: imgHeight)
        self.imageHeight = (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : UIScreen.main.bounds.width
    }
    
    private func calculateHeight(width: Double, height: Double) -> CGFloat {
        let divider = width / UIScreen.main.bounds.size.width
        return height / divider
    }
}

struct ImageRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
        // ImageRow(status: [])
    }
}
