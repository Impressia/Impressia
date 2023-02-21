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
    private let open: () -> Void
    private let upload: () -> Void
    
    public init(photoAttachment: PhotoAttachment, open: @escaping () -> Void, delete: @escaping () -> Void, upload: @escaping () -> Void) {
        self.photoAttachment = photoAttachment
        self.delete = delete
        self.open = open
        self.upload = upload
    }
    
    var body: some View {
        if let uiImage = UIImage(data: photoAttachment.photoData) {
            
            if photoAttachment.error != nil {
                Menu {
                    Button {
                        HapticService.shared.fireHaptic(of: .buttonPress)
                        self.upload()
                    } label: {
                        Label("Try to upload", systemImage: "exclamationmark.arrow.triangle.2.circlepath")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        HapticService.shared.fireHaptic(of: .buttonPress)
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
                    Button {
                        HapticService.shared.fireHaptic(of: .buttonPress)
                        self.open()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        HapticService.shared.fireHaptic(of: .buttonPress)
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
