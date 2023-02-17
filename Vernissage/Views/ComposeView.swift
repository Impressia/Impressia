//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import PhotosUI
import MastodonKit

struct ComposeView: View {
    enum FocusField: Hashable {
        case unknown
        case content
    }
    
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var routerPath: RouterPath
    @EnvironmentObject var client: Client

    @Environment(\.dismiss) private var dismiss
    
    @State var statusViewModel: StatusModel?
    @State private var text = String.empty()
    @State private var publishDisabled = true
    
    @State private var photosAreUploading = false
    @State private var photosPickerVisible = false

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var photosAttachment: [PhotoAttachment] = []

    @FocusState private var focusedField: FocusField?
    
    private let contentWidth = Int(UIScreen.main.bounds.width) - 50
    
    var body: some View {
        NavigationStack {
            NavigationView {
                ScrollView {
                    VStack (alignment: .leading){
                        if let accountData = applicationState.account {
                            HStack {
                                UsernameRow(
                                    accountId: accountData.id,
                                    accountAvatar: accountData.avatar,
                                    accountDisplayName: accountData.displayName,
                                    accountUsername: accountData.username)
                                Spacer()
                            }
                            .padding(8)
                        }
                        
                        TextField("Type what's on your mind", text: $text)
                            .padding(8)
                            .focused($focusedField, equals: .content)
                            .keyboardType(.twitter)
                            .task {
                                self.focusedField = .content
                            }
                            .onChange(of: self.text) { newValue in
                                self.publishDisabled = self.isPublishButtonDisabled()
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    HStack(alignment: .center) {
                                        Button {
                                            hideKeyboard()
                                            self.focusedField = .unknown
                                            self.photosPickerVisible = true
                                        } label: {
                                            Image(systemName: "photo.on.rectangle.angled")
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        
                        HStack(alignment: .center) {
                            ForEach(self.photosAttachment, id: \.id) { photoAttachment in
                                ImageUploadView(photoAttachment: photoAttachment)
                            }
                        }
                        .padding(8)
                        
                        if let status = self.statusViewModel {
                            HStack (alignment: .top) {                            
                                UserAvatar(accountAvatar: status.account.avatar, size: .comment)
                                
                                VStack (alignment: .leading, spacing: 0) {
                                    HStack (alignment: .top) {
                                        Text(statusViewModel?.account.displayNameWithoutEmojis ?? "")
                                            .foregroundColor(.mainTextColor)
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                    }
                                    
                                    MarkdownFormattedText(status.content.asMarkdown, withFontSize: 14, andWidth: contentWidth)
                                        .environment(\.openURL, OpenURLAction { url in .handled })
                                }
                            }
                            .padding(8)
                            .background(Color.selectedRowColor)
                        }
                        
                        Spacer()
                    }
                }
                .frame(alignment: .topLeading)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            Task {
                                await self.publishStatus()
                                dismiss()
                            }
                        } label: {
                            Text("Publish")
                                .foregroundColor(.white)
                        }
                        .disabled(self.publishDisabled)
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    }
                    
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                    }
                }
                .onChange(of: self.selectedItems) { selectedItem in
                    Task {
                        await self.loadPhotos()
                    }
                }
                .photosPicker(isPresented: $photosPickerVisible, selection: $selectedItems, maxSelectionCount: 4, matching: .images)
                .navigationBarTitle(Text("Compose"), displayMode: .inline)
            }
            .withAppRouteur()
            .withOverlayDestinations(overlayDestinations: $routerPath.presentedOverlay)
        }
        .interactiveDismissDisabled(!self.text.isEmpty)
    }
    
    private func isPublishButtonDisabled() -> Bool {
        // Publish always disabled when there is not status text.
        if self.text.isEmpty {
            return true
        }
        
        // When application is during uploading photos we cannot send new status.
        if self.photosAreUploading == true {
            return true
        }
        
        // When status is not a comment, then photo is required.
        if self.statusViewModel == nil && self.photosAttachment.hasUploadedPhotos() == false {
            return true
        }
        
        return false
    }
    
    private func loadPhotos() async {
        do {
            self.photosAreUploading = true
            self.photosAttachment = []
            self.publishDisabled = self.isPublishButtonDisabled()
            
            for item in self.selectedItems {
                if let photoData = try await item.loadTransferable(type: Data.self) {
                    self.photosAttachment.append(PhotoAttachment(photosPickerItem: item, photoData: photoData))
                }
            }
            
            self.focusedField = .content
            await self.upload()
            
            self.photosAreUploading = false
            self.publishDisabled = self.isPublishButtonDisabled()
        } catch {
            ErrorService.shared.handle(error, message: "Cannot retreive image from library.", showToastr: true)
        }
    }
    
    private func upload() async {
        for (index, photoAttachment) in self.photosAttachment.enumerated() {
            do {
                if let mediaAttachment = try await self.client.media?.upload(data: photoAttachment.photoData,
                                                                             fileName: "file-\(index).jpg",
                                                                             mimeType: "image/jpeg") {
                    photoAttachment.uploadedAttachment = mediaAttachment
                }
            } catch {
                photoAttachment.error = error
                ErrorService.shared.handle(error, message: "Error during post photo.", showToastr: true)
            }
        }
    }
    
    private func publishStatus() async {
        do {
            let status = self.createStatus()
            if let newStatus = try await self.client.statuses?.new(status: status) {
                ToastrService.shared.showSuccess("Status published", imageSystemName: "message.fill")

                let statusModel = StatusModel(status: newStatus)
                let commentModel = CommentModel(status: statusModel, showDivider: false)
                self.applicationState.newComment = commentModel
            }
        } catch {
            ErrorService.shared.handle(error, message: "Error during post status.", showToastr: true)
        }
    }
    
    private func createStatus() -> Mastodon.Statuses.Components {
        return Mastodon.Statuses.Components(inReplyToId: self.statusViewModel?.id,
                                            text: self.text,
                                            mediaIds: self.photosAttachment.getUploadedPhotoIds())
    }
}
