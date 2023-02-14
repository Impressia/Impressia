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
    @EnvironmentObject var client: Client
    @Environment(\.dismiss) private var dismiss
    
    @State var statusViewModel: StatusModel?
    @State private var text = String.empty()
    
    @State private var photosPickerVisible = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var photosData: [Data] = []

    @FocusState private var focusedField: FocusField?
    
    private let contentWidth = Int(UIScreen.main.bounds.width) - 50
    
    var body: some View {
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
                        .task {
                            self.focusedField = .content
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
                        ForEach(self.photosData, id: \.self) { photoData in
                            if let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }


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
                            ToastrService.shared.showSuccess("Status published", imageSystemName: "message.fill")
                        }
                    } label: {
                        Text("Publish")
                            .foregroundColor(.white)
                    }
                    .disabled(self.text.isEmpty)
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
                self.photosData = []

                for item in self.selectedItems {
                    item.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data {
                                self.photosData.append(data)
                            } else {
                                ToastrService.shared.showError(subtitle: "Cannot show image preview.")
                            }
                        case .failure(let error):
                            ErrorService.shared.handle(error, message: "Cannot retreive image from library.", showToastr: true)
                        }
                    }
                    
                    self.focusedField = .content
                }
            }
            .photosPicker(isPresented: $photosPickerVisible, selection: $selectedItems, maxSelectionCount: 4, matching: .images)
            .navigationBarTitle(Text("Compose"), displayMode: .inline)
        }
    }
    
    private func publishStatus() async {
        do {
            if let newStatus = try await self.client.statuses?.new(status:Mastodon.Statuses.Components(inReplyToId: self.statusViewModel?.id, text: self.text)) {
                let statusModel = StatusModel(status: newStatus)
                let commentModel = CommentModel(status: statusModel, showDivider: false)
                self.applicationState.newComment = commentModel
            }
        } catch {
            ErrorService.shared.handle(error, message: "Error during post status.", showToastr: true)
        }
    }
}
