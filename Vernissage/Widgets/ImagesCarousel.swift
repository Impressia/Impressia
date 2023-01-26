//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit

struct ImagesCarousel: View {
    @State public var attachments: [AttachmentViewModel]
    @State private var imageHeight: Double
    @State private var imageWidth: Double
    @State private var selected: String
    @State private var heightWasPrecalculated: Bool
    
    @Binding public var selectedAttachmentId: String?
    @Binding public var exifCamera: String?
    @Binding public var exifExposure: String?
    @Binding public var exifCreatedDate: String?
    @Binding public var exifLens: String?
    
    init(attachments: [AttachmentViewModel],
         selectedAttachmentId: Binding<String?>,
         exifCamera: Binding<String?>,
         exifExposure: Binding<String?>,
         exifCreatedDate: Binding<String?>,
         exifLens: Binding<String?>
    ) {
        _selectedAttachmentId = selectedAttachmentId
        _exifCamera = exifCamera
        _exifExposure = exifExposure
        _exifCreatedDate = exifCreatedDate
        _exifLens = exifLens
        
        self.attachments = attachments
        self.selected = String.empty()

        var imgHeight = 0.0
        var imgWidth = 0.0

        for item in attachments {
            let attachmentheight = Double((item.meta as? ImageMetadata)?.original?.height ?? 0)
            if attachmentheight > imgHeight {
                imgHeight = attachmentheight
                imgWidth = Double((item.meta as? ImageMetadata)?.original?.width ?? 0)
            }
        }
        
        if imgHeight > 0 && imgWidth > 0 {
            let divider = Double(imgWidth) / UIScreen.main.bounds.size.width
            let calculatedHeight = Double(imgHeight) / divider
            
            self.imageWidth = UIScreen.main.bounds.width
            self.imageHeight = (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : UIScreen.main.bounds.width
            self.heightWasPrecalculated = true
        } else {
            self.imageWidth = UIScreen.main.bounds.width
            self.imageHeight = UIScreen.main.bounds.width * 0.75
            self.heightWasPrecalculated = false
        }
    }
    
    var body: some View {
        TabView(selection: $selected) {
            ForEach(attachments, id: \.id) { attachment in
                ImageCarouselPicture(attachment: attachment) { (attachment, imageData) in
                    withAnimation {
                        self.recalculateImageHeight(imageData: imageData)   
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        attachment.set(data: imageData)
                    }
                    
                }
                .tag(attachment.id)
            }
        }
        .frame(height: CGFloat(self.imageHeight))
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
        }
    }
    
    private func recalculateImageHeight(imageData: Data) {
        guard heightWasPrecalculated == false else {
            return
        }

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
        
        if let image = UIImage(data: imageData) {
            if image.size.height > imageHeight {
                imageHeight = image.size.height
                imageWidth = image.size.width
            }
        }
        
        let divider = imageWidth / UIScreen.main.bounds.size.width
        self.imageHeight = imageHeight / divider
    }
}
