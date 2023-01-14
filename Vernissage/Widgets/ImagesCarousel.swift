//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct ImagesCarousel: View {
    @State public var attachments: [AttachmentViewModel]
    @State private var height: Double = 0.0
    @State private var selected = String.empty()
    
    @Binding public var selectedAttachmentId: String?
    @Binding public var exifCamera: String?
    @Binding public var exifExposure: String?
    @Binding public var exifCreatedDate: String?
    @Binding public var exifLens: String?
    
    var body: some View {
        TabView(selection: $selected) {
            ForEach(attachments, id: \.id) { attachment in
                if let data = attachment.data, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(attachment.id)
                }
            }
        }
        .frame(height: CGFloat(self.height))
        .tabViewStyle(PageTabViewStyle())
        .onChange(of: selected, perform: { index in
            self.selectedAttachmentId = selected

            if let attachment = attachments.first(where: { item in item.id == index }) {
                self.exifCamera = attachment.exifCamera
                self.exifExposure = attachment.exifExposure
                self.exifCreatedDate = attachment.exifCreatedDate
                self.exifLens = attachment.exifLens
            }
        })
        .onAppear {
            self.selected = self.attachments.first?.id ?? String.empty()
            self.calculateImageHeight()
        }
    }
    
    private func calculateImageHeight() {
        var imageHeight = 0.0
        var imageWidth = 0.0
        
        for item in attachments {
            if let data = item.data, let image = UIImage(data: data) {
                if image.size.height > imageHeight {
                    imageHeight = image.size.height
                    imageWidth = image.size.width
                }
            }
        }
        
        let divider = imageWidth / UIScreen.main.bounds.size.width
        self.height = imageHeight / divider
    }
}

struct ImagesCarousel_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
        // ImagesCarousel(attachments: [], exifCamera: .constant(""), exifExposure: .constant(""), exifCreatedDate: .constant(""), exifLens: .constant(""))
    }
}
