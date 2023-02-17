//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct PhotoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var description: String = String.empty()
    @State public var alt = String.empty()
    @State public var sensitive = false
    @State public var commentingOff = false
    
    @ObservedObject public var photoAttachment: PhotoAttachment
        
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
            
            Form {
                Section(header: Text("Input")) {
                    TextInputField("Alt text", text: $alt)
                        .keyboardType(.default)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                    
                    TextInputField("Add description for the visually impaired", text: $description)
                        .keyboardType(.default)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                    
                    Toggle("Sensitive/NSFW Media", isOn: $sensitive)
                    Toggle("Turn off commenting", isOn: $commentingOff)
                }
            }
                
            Spacer()
        }
        .onAppear {
            self.description = self.photoAttachment.description
            self.alt = self.photoAttachment.alt
            self.sensitive = self.photoAttachment.sensitive
            self.commentingOff = self.photoAttachment.commentingOff
        }
        .navigationBarTitle("Description")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            self.getTrailingToolbar()
        }
    }
    
    @ToolbarContentBuilder
    private func getTrailingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                HapticService.shared.touch()
                self.photoAttachment.description = self.description
                self.photoAttachment.alt = self.alt
                self.photoAttachment.sensitive = self.sensitive
                self.photoAttachment.commentingOff = self.commentingOff
                
                self.dismiss()
            } label: {
                Text("Update")
            }.buttonStyle(.borderedProminent)
        }
    }
}

