//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct ImageUploadView: View {
    @EnvironmentObject public var routerPath: RouterPath
    @ObservedObject public var photoAttachment: PhotoAttachment
    
    var body: some View {
        if let uiImage = UIImage(data: photoAttachment.photoData) {
            
            if photoAttachment.uploadedAttachment == nil {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .blur(radius: 10)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                        LoadingIndicator(isVisible: Binding.constant(true))
                    }
            } else {
                NavigationLink(value: RouteurDestinations.photoEditor(photoAttachment: photoAttachment)) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}
