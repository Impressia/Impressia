//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct ImageUploadView: View {
    @EnvironmentObject public var routerPath: RouterPath
    @ObservedObject public var photoAttachment: PhotoAttachment
    
    private let delete: () -> Void
    
    public init(photoAttachment: PhotoAttachment, delete: @escaping () -> Void) {
        self.photoAttachment = photoAttachment
        self.delete = delete
    }
    
    var body: some View {
        if let uiImage = UIImage(data: photoAttachment.photoData) {
            
            if photoAttachment.error != nil {
                Menu {
                    Button(role: .destructive) {
                        self.delete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .tint(.red)
                    }
                } label: {
                    ZStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .blur(radius: 10)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                            Image(systemName: "exclamationmark.triangle.fill")
                        }
                }
            } else if photoAttachment.uploadedAttachment == nil {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .blur(radius: 10)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                        LoadingIndicator(isVisible: Binding.constant(true))
                    }
            } else {
                Menu {
                    NavigationLink(value: RouteurDestinations.photoEditor(photoAttachment: photoAttachment)) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        self.delete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}
