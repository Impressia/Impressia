//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ImageRow: View {
    private let status: StatusData
    private let imageHeight: Double
    private let imageWidth: Double
    private let uiImage:UIImage?
    private let attachmentData: AttachmentData?
    
    init(statusData: StatusData) {
        self.status = statusData
        self.attachmentData = statusData.attachments().first
        
        if let attachmenData = self.attachmentData, let uiImage = UIImage(data: attachmenData.data) {
            self.uiImage = uiImage
            
            let imgHeight = uiImage.size.height
            let imgWidth = uiImage.size.width
            let divider = imgWidth / UIScreen.main.bounds.size.width
            let calculatedHeight = imgHeight / divider
            
            self.imageWidth = UIScreen.main.bounds.width
            self.imageHeight = (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : UIScreen.main.bounds.width
        } else {
            self.uiImage = nil
            self.imageHeight = UIScreen.main.bounds.width
            self.imageWidth = UIScreen.main.bounds.width
        }
    }
    
    var body: some View {
        if let uiImage, let attachmentData {
            ZStack {
                if self.status.sensitive {
                    ContentWarning(blurhash: attachmentData.blurhash, spoilerText: self.status.spoilerText) {
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
        }
    }
}

struct ImageRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
        // ImageRow(status: [])
    }
}
