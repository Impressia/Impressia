//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct PhotoEditorView: View {
    @State public var photoAttachment: PhotoAttachment
    
    var body: some View {
        VStack(alignment: .leading) {
            if let uiImage = UIImage(data: photoAttachment.photoData) {
                HStack {
                    Spacer()
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Spacer()
                }
            }
            
            TextField("Add description for the visually impaired.", text: $photoAttachment.description, axis: .vertical)
                .keyboardType(.default)
                .lineLimit(4, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .textFieldStyle(.roundedBorder)
                .padding(8)
                
            Spacer()
        }
    }
}
