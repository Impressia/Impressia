//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import PhotosUI
import PixelfedKit
import ClientKit
import EnvironmentKit
import ServicesKit

@MainActor
public struct BaseComposeView: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(Client.self) var client

    @State private var textModel: TextModel

    @State private var isKeyboardPresented = true
    @State private var isSensitive: Bool
    @State private var spoilerText: String
    @State private var commentsDisabled: Bool
    @State private var place: Place?

    @State private var photosAreAttached = false
    @State private var publishDisabled = true
    @State private var interactiveDismissDisabled = false
    @State private var isLoadingExistingAttachments = true

    @State private var photosAreUploading = false
    @State private var photosPickerVisible = false
    @State private var draggedItem: PhotoAttachment?

    /// Images from camera pickler.
    @State private var images: [UIImage] = []

    /// Images from share sheet  or files application.
    @State private var attachments: [NSItemProvider]

    /// Images from Photos app.
    @State private var selectedItems: [PhotosPickerItem] = []

    /// Processed array with images.
    @State private var photosAttachment: [PhotoAttachment]

    @State private var isCameraPickerPresented: Bool = false
    @State private var isFileImporterPresented: Bool = false

    @State private var showAltAlert = false
    @State private var visibility = Pixelfed.Statuses.Visibility.pub
    @State private var visibilityText: LocalizedStringKey = "compose.title.everyone"
    @State private var visibilityImage = "globe.europe.africa"

    @FocusState private var focusedField: FocusField?
    enum FocusField: Hashable {
        case unknown
        case content
        case spoilerText
    }

    @State private var showSheet: SheetType?
    @State private var existingAttachments: [AttachmentModel] = []

    enum SheetType: Identifiable {
        case photoDetails(PhotoAttachment)
        case existingAttachmentEditor(AttachmentModel)
        case placeSelector

        public var id: String {
            switch self {
            case .photoDetails:
                return "photoDetails"
            case .existingAttachmentEditor:
                return "existingAttachmentEditor"
            case .placeSelector:
                return "placeSelector"
            }
        }
    }

    /// Determines the rules for the publish button when editing an existing status.
    /// Deduced automatically from `statusToEdit.inReplyToId`:
    /// - `.comment` (inReplyToId != nil) — text required, photo optional
    /// - `.photo`   (inReplyToId == nil) — photo required, text optional
    public enum EditMode {
        case comment
        case photo
    }

    private let statusViewModel: StatusModel?
    private let statusToEdit: StatusModel?
    private let editMode: EditMode?
    private let initialText: String?
    private let initialDescriptions: [String: String?]
    private let imageSize = 115.0
    private let keyboardFontImageSize = 20.0
    private let keyboardFontTextSize = 16.0
    private let autocompleteFontTextSize = 12.0

    private let onClose: () -> Void
    private let onUpload: (PhotoAttachment) async -> Void

    public init(statusViewModel: StatusModel? = nil,
                attachments: [NSItemProvider] = [],
                onClose: @escaping () -> Void,
                onUpload: @escaping (PhotoAttachment) async -> Void) {
        self.statusViewModel = statusViewModel
        self.statusToEdit = nil
        self.editMode = nil
        self.initialText = nil
        self.initialDescriptions = [:]
        self.attachments = attachments
        self.onClose = onClose
        self.onUpload = onUpload
        self.draggedItem = nil

        self._photosAttachment = .init(initialValue: [])
        self._textModel = .init(initialValue: .init())
        self._isSensitive = .init(initialValue: false)
        self._spoilerText = .init(initialValue: "")
        self._commentsDisabled = .init(initialValue: false)
    }

    public init(statusToEdit: StatusModel,
                onClose: @escaping () -> Void,
                onUpload: @escaping (PhotoAttachment) async -> Void) {
        self.statusToEdit = statusToEdit
        self.statusViewModel = nil
        // Deduce edit mode from inReplyToId: a reply is a comment, otherwise it's a photo post.
        self.editMode = statusToEdit.inReplyToId != nil ? .comment : .photo
        self.attachments = []
        self.onClose = onClose
        self.onUpload = onUpload
        self.draggedItem = nil

        // Pre-compute plain text from HTML to pre-fill the editor on first appear.
        self.initialText = statusToEdit.content.htmlValue
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "<br/>", with: "\n")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        // Store initial alt text descriptions to detect changes.
        self.initialDescriptions = Dictionary(
            uniqueKeysWithValues: statusToEdit.mediaAttachments.map { ($0.id, $0.description) }
        )

        self._textModel = .init(initialValue: .init())
        self._place = .init(initialValue: statusToEdit.place)
        self._isSensitive = .init(initialValue: statusToEdit.sensitive)
        self._spoilerText = .init(initialValue: statusToEdit.spoilerText ?? "")
        self._commentsDisabled = .init(initialValue: statusToEdit.commentsDisabled)

        // Pre-populate existing media as synthetic PhotoAttachments synchronously.
        // Done in init (not .task) to ensure photos appear on first render.
        self._photosAttachment = .init(initialValue: statusToEdit.mediaAttachments.map {
            PhotoAttachment(attachmentModel: $0)
        })
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            self.composeBody()

            if self.isKeyboardPresented {
                VStack(alignment: .leading, spacing: 0) {
                    self.autocompleteToolbar()
                    self.keyboardToolbar()
                }
                .transition(.opacity)
            }
        }
        .frame(alignment: .topLeading)
        .task {
            // Fetch fresh status to get up-to-date media attachments with their alt texts.
            if let statusToEdit {
                if let freshStatus = try? await self.client.statuses?.status(withId: statusToEdit.id) {
                    self.existingAttachments = freshStatus.mediaAttachments.map { AttachmentModel(attachment: $0) }
                } else {
                    self.existingAttachments = statusToEdit.mediaAttachments
                }
                self.isLoadingExistingAttachments = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await self.publishStatus()
                    }
                } label: {
                    if self.statusToEdit != nil {
                        Text("compose.title.edit", bundle: Bundle.module, comment: "Edit")
                    } else {
                        Text("compose.title.publish", bundle: Bundle.module, comment: "Publish")
                    }
                }
                .disabled(self.publishDisabled)
                .buttonStyle(.borderedProminent)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(NSLocalizedString("compose.title.cancel", bundle: Bundle.module, comment: "Cancel"), role: .cancel) {
                    self.close()
                }
            }
        }
        .onAppear {
            self.textModel.client = self.client
            // Pre-fill text — done here because TextModel.textView is nil until the view appears.
            if let initialText, !initialText.isEmpty {
                self.asyncAfter(0.1) {
                    self.textModel.text = NSMutableAttributedString(string: initialText)
                    self.textModel.selectedRange = NSRange(location: initialText.utf16.count, length: 0)
                }
            }
            // In edit mode, photos are pre-populated from the existing status —
            // calling loadPhotos() would erase the synthetic PhotoAttachments.
            if self.statusToEdit == nil {
                Task {
                    await self.loadPhotos()
                }
            }
        }
        .onChange(of: self.textModel.text) {
            self.refreshScreenState()
        }
        .onChange(of: self.isSensitive) {
            self.refreshScreenState()
        }
        .onChange(of: self.commentsDisabled) {
            self.refreshScreenState()
        }
        .onChange(of: self.place?.id) {
            self.refreshScreenState()
        }
        .onChange(of: self.existingAttachments.map { $0.description ?? "" }.joined()) {
            self.refreshScreenState()
        }
        .onChange(of: self.selectedItems) {
            Task {
                await self.loadPhotos()
            }
        }
        .sheet(item: $showSheet, content: { sheetType in
            switch sheetType {
            case .photoDetails(let photoAttachment):
                PhotoEditorView(photoAttachment: photoAttachment)
            case .existingAttachmentEditor(let attachmentModel):
                ExistingAttachmentEditorView(attachment: attachmentModel) { newDescription in
                    if let index = self.existingAttachments.firstIndex(where: { $0.id == attachmentModel.id }) {
                        self.existingAttachments[index].description = newDescription
                    }
                }
            case .placeSelector:
                PlaceSelectorView(place: $place)
            }
        })
        .onReceive(keyboardPublisher) { value in
            withAnimation {
                self.isKeyboardPresented = value
            }
        }
        .photosPicker(isPresented: $photosPickerVisible,
                      selection: $selectedItems,
                      maxSelectionCount: self.applicationState.statusMaxMediaAttachments,
                      matching: .images)
        .fileImporter(isPresented: $isFileImporterPresented,
                      allowedContentTypes: [.image],
                      allowsMultipleSelection: true) { result in
            Task {
                if let urls = try? result.get() {
                    await self.processFiles(urls: urls)
                }
            }
        }
        .fullScreenCover(isPresented: $isCameraPickerPresented, content: {
            CameraPickerView(selectedImage: .init(
                get: { nil },
                set: { image in
                    if let image {
                        self.images.append(image)

                        Task {
                            await self.loadPhotos()
                        }
                    }
                }
            ))
            .background(.black)
        })
        .alert(isPresented: $showAltAlert, content: {
            Alert(title: Text("compose.title.missingAltTexts", bundle: Bundle.module, comment: "Missing ALT texts"),
                  message: Text("compose.title.missingAltTextsWarning", bundle: Bundle.module, comment: "Missing ALT texts warning"),
                  primaryButton: .default(Text("compose.title.publish", bundle: Bundle.module, comment: "Publish")) {
                      Task {
                          await self.sendToServer()
                      }
                  },
                  secondaryButton: .cancel(Text("compose.title.cancel", bundle: Bundle.module, comment: "Cancel")))
        })
        .interactiveDismissDisabled(self.interactiveDismissDisabled)
    }

    @ViewBuilder
    private func composeBody() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Red content warning.
                self.contentWarningView()

                // Information that comments are disabled.
                self.commentsDisabledView()

                // User avatar and name.
                self.userAvatarView()

                // Information about status visibility.
                self.visibilityComboView()

                // Text area with new status.
                self.statusTextView()

                // Grid with images — existing attachments in edit mode, new uploads otherwise.
                if self.statusToEdit != nil {
                    if self.isLoadingExistingAttachments {
                        HStack {
                            Spacer()
                            LoadingIndicator()
                            Spacer()
                        }
                        .frame(height: self.imageSize)
                    } else {
                        self.existingImagesGridView()
                    }
                } else {
                    self.imagesGridView()
                }

                // Status when we are adding new comment.
                self.statusModelView()

                Spacer()
            }
        }
        // Space for keyboard toolbar.
        .padding(.bottom, 40)
    }

    @ViewBuilder
    private func imagesGridView() -> some View {
        HStack(alignment: .center) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: self.imageSize))]) {
                ForEach(self.photosAttachment, id: \.id) { photoAttachment in
                    ImageUploadView(photoAttachment: photoAttachment, size: self.imageSize) {
                        self.showSheet = .photoDetails(photoAttachment)
                    } delete: {
                        // Existing server attachments cannot be removed when editing a post.
                        guard !photoAttachment.isExistingAttachment else { return }

                        self.photosAttachment = self.photosAttachment.filter({ item in
                            item != photoAttachment
                        })

                        self.selectedItems = self.selectedItems.filter({ item in
                            item != photoAttachment.photosPickerItem
                        })

                        self.attachments = self.attachments.filter({ item in
                            item != photoAttachment.nsItemProvider
                        })

                        self.images = self.images.filter({ item in
                            item != photoAttachment.uiImage
                        })

                        self.refreshScreenState()
                    } upload: {
                        Task {
                            photoAttachment.uploadError = nil
                            await self.onUpload(photoAttachment)
                            self.refreshScreenState()
                        }
                    }
                    .onDrag({
                        self.draggedItem = photoAttachment
                        return NSItemProvider()
                    })
                    .onDrop(of: [UTType.text], delegate: PhotoDropDelegate(item: photoAttachment, items: $photosAttachment, draggedItem: $draggedItem))
                }
            }
        }
        .padding(8)
    }

    @ViewBuilder
    private func existingImagesGridView() -> some View {
        if !existingAttachments.isEmpty {
            HStack(alignment: .center) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: self.imageSize))]) {
                    ForEach(existingAttachments, id: \.id) { attachment in
                        ZStack(alignment: .bottom) {
                            AsyncImage(url: attachment.previewUrl ?? attachment.url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: self.imageSize - 6, height: self.imageSize - 6)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                default:
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(width: self.imageSize - 6, height: self.imageSize - 6)
                                }
                            }
                            .onTapGesture {
                                self.showSheet = .existingAttachmentEditor(attachment)
                            }

                            // ALT badge — tappable, opens the alt text editor.
                            HStack {
                                Spacer()
                                HStack {
                                    Group {
                                        if (attachment.description ?? "").isEmpty {
                                            Image(systemName: "exclamationmark.circle.fill")
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(Color.white, Color.dangerColor)
                                                .accessibilityHidden(true)
                                        } else {
                                            Image(systemName: "checkmark.circle.fill")
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(Color.white, Color.systemGreen)
                                                .accessibilityHidden(true)
                                        }
                                        Text("status.title.altText", bundle: Bundle.module, comment: "ALT")
                                            .foregroundStyle(Color.white)
                                    }
                                    .font(.system(size: 12))
                                    .shadow(color: .black, radius: 4)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.black.opacity(0.8)))
                                .padding(.bottom, 4)
                                .padding(.trailing, 12)
                                .opacity(0.75)
                                .onTapGesture {
                                    self.showSheet = .existingAttachmentEditor(attachment)
                                }
                            }
                        }
                        .frame(width: self.imageSize, height: self.imageSize)
                    }
                }
            }
            .padding(8)
        }
    }

    @ViewBuilder
    private func statusModelView() -> some View {
        if let status = self.statusViewModel {
            HStack(alignment: .top) {
                UserAvatar(accountAvatar: status.account.avatar, size: .comment)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Text(statusViewModel?.account.displayNameWithoutEmojis ?? "")
                            .foregroundColor(.mainTextColor)
                            .font(.footnote)
                            .fontWeight(.bold)

                        Spacer()
                    }

                    MarkdownFormattedText(status.content.asMarkdown)
                        .font(.subheadline)
                        .environment(\.openURL, OpenURLAction { _ in .handled })
                }
            }
            .padding(8)
            .background(Color.selectedRowColor)
        }
    }

    @ViewBuilder
    private func statusTextView() -> some View {
        TextView($textModel.text, getTextView: { textView in
            self.textModel.textView = textView
        })
        .placeholder(LocalizedStringKey(self.placeholder()))
        .padding(.horizontal, 8)
        .focused($focusedField, equals: .content)
        .onFirstAppear {
            self.focusedField = .content
        }
    }

    @ViewBuilder
    private func userAvatarView() -> some View {
        if let accountData = applicationState.account {
            HStack {
                UsernameRow(
                    accountId: accountData.id,
                    accountAvatar: accountData.avatar,
                    accountDisplayName: accountData.displayName,
                    accountUsername: accountData.username)
                Spacer()
            }
            .padding(.horizontal, 8)
        }
    }

    @ViewBuilder
    private func contentWarningView() -> some View {
        if self.isSensitive {
            TextField(NSLocalizedString("compose.title.writeContentWarning", bundle: Bundle.module, comment: "Content warning"), text: $spoilerText, axis: .vertical)
                .padding(8)
                .lineLimit(1...2)
                .focused($focusedField, equals: .spoilerText)
                .keyboardType(.default)
                .background(Color.dangerColor.opacity(0.4))
        }
    }

    @ViewBuilder
    private func commentsDisabledView() -> some View {
        if self.commentsDisabled {
            HStack {
                Spacer()
                Text("compose.title.commentsWillBeDisabled", bundle: Bundle.module, comment: "Comments disabled")
                    .textCase(.uppercase)
                    .font(.caption2)
                    .foregroundColor(.dangerColor)
            }
            .padding(.horizontal, 8)
        }
    }

    @ViewBuilder
    private func visibilityComboView() -> some View {
        HStack {
            Menu {
                Button {
                    self.visibility = .pub
                    self.visibilityText = "compose.title.everyone"
                    self.visibilityImage = "globe.europe.africa"
                } label: {
                    Label {
                        Text("compose.title.everyone", bundle: Bundle.module, comment: "Everyone")
                    } icon: {
                        Image(systemName: "globe.europe.africa")
                    }
                }

                Button {
                    self.visibility = .unlisted
                    self.visibilityText = "compose.title.unlisted"
                    self.visibilityImage = "lock.open"
                } label: {
                    Label {
                        Text("compose.title.unlisted", bundle: Bundle.module, comment: "Unlisted")
                    } icon: {
                        Image(systemName: "lock.open")
                    }
                }

                Button {
                    self.visibility = .priv
                    self.visibilityText = "compose.title.followers"
                    self.visibilityImage = "lock"
                } label: {
                    Label {
                        Text("compose.title.followers", bundle: Bundle.module, comment: "Followers")
                    } icon: {
                        Image(systemName: "lock")
                    }
                }
            } label: {
                HStack {
                    Label {
                        Text(self.visibilityText, bundle: Bundle.module, comment: "Visibility text")
                    } icon: {
                        Image(systemName: self.visibilityImage)
                    }
                    Image(systemName: "chevron.down")
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
            }
            .disabled(self.statusToEdit != nil)

            Spacer()

            if let name = self.place?.name, let country = self.place?.country {
                Group {
                    Image(systemName: "mappin.and.ellipse").accessibilityHidden(true)
                    Text("\(name), \(country)")
                }
                .foregroundColor(.customGrayColor)
                .padding(.trailing, 8)
            }
        }
        .font(.footnote)
        .padding(.horizontal, 8)
    }

    @ViewBuilder
    private func autocompleteToolbar() -> some View {
        if !textModel.mentionsSuggestions.isEmpty || !textModel.tagsSuggestions.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    if !textModel.mentionsSuggestions.isEmpty {
                        ForEach(textModel.mentionsSuggestions, id: \.id) { account in
                            Button {
                                textModel.selectMentionSuggestion(account: account)
                            } label: {
                                HStack(alignment: .center) {
                                    UserAvatar(accountAvatar: account.avatar, size: .comment)

                                    VStack(alignment: .leading) {
                                        Text(account.displayNameWithoutEmojis)
                                            .foregroundColor(.mainTextColor)
                                        Text("@\(account.acct)")
                                            .foregroundColor(.customGrayColor)
                                    }
                                    .padding(.leading, 8)
                                }
                                .font(.system(size: self.autocompleteFontTextSize))
                                .padding(.trailing, 8)
                            }
                            Divider()
                        }
                    } else {
                        ForEach(textModel.tagsSuggestions, id: \.url) { tag in
                            Button {
                                textModel.selectHashtagSuggestion(tag: tag)
                            } label: {
                                Text("#\(tag.name)")
                                    .font(.system(size: self.autocompleteFontTextSize))
                                    .foregroundColor(self.applicationState.tintColor.color())
                            }
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(height: 40)
            .background(.ultraThinMaterial)
        }
    }

    @ViewBuilder
    private func keyboardToolbar() -> some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                ScrollView(.horizontal) {
                    HStack(alignment: .center, spacing: 20) {
                        Menu {
                            Button {
                                hideKeyboard()
                                self.focusedField = .unknown
                                self.photosPickerVisible = true
                            } label: {
                                Label {
                                    Text("compose.title.photos", bundle: Bundle.module, comment: "Photo")
                                } icon: {
                                    Image(systemName: "photo")
                                }
                            }

                            Button {
                                hideKeyboard()
                                self.focusedField = .unknown
                                self.isCameraPickerPresented = true
                            } label: {
                                Label {
                                    Text("compose.title.camera", bundle: Bundle.module, comment: "Camera")
                                } icon: {
                                    Image(systemName: "camera")
                                }
                            }

                            Button {
                                hideKeyboard()
                                self.focusedField = .unknown
                                isFileImporterPresented = true
                            } label: {
                                Label {
                                    Text("compose.title.files", bundle: Bundle.module, comment: "Files")
                                } icon: {
                                    Image(systemName: "folder")
                                }
                            }
                        } label: {
                            Image(systemName: self.photosAreAttached ? "photo.fill.on.rectangle.fill" : "photo.on.rectangle")
                                .accessibilityLabel(Text("compose.title.photos", bundle: .module))
                        }
                        // Disabled in edit mode — existing photos cannot be added or removed.
                        .disabled(self.statusToEdit != nil)

                        Button {
                            withAnimation(.easeInOut) {
                                self.isSensitive.toggle()

                                if self.isSensitive {
                                    self.focusedField = .spoilerText
                                } else {
                                    self.focusedField = .content
                                }
                            }
                        } label: {
                            if self.isSensitive {
                                Image(systemName: "exclamationmark.square.fill")
                                    .accessibilityLabel(Text("compose.title.a11y.removeContentWarning", bundle: .module))
                            } else {
                                Image(systemName: "exclamationmark.square")
                                    .accessibilityLabel(Text("compose.title.a11y.addContentWarning", bundle: .module))
                            }
                        }

                        Button {
                            withAnimation(.easeInOut) {
                                self.commentsDisabled.toggle()
                            }
                        } label: {
                            if self.commentsDisabled {
                                Image(systemName: "person.2.slash")
                                    .accessibilityLabel(Text("compose.title.a11y.enableComment", bundle: .module))
                            } else {
                                Image(systemName: "person.2.fill")
                                    .accessibilityLabel(Text("compose.title.a11y.disableComment", bundle: .module))
                            }
                        }
                        .disabled(self.statusToEdit != nil)

                        Button {
                            if self.place != nil {
                                withAnimation(.easeInOut) {
                                    self.place = nil
                                }
                            } else {
                                self.showSheet = .placeSelector
                            }
                        } label: {
                            if self.place == nil {
                                Image(systemName: "mappin.square")
                                    .accessibilityLabel(Text("compose.title.a11y.addLocation", bundle: .module))
                            } else {
                                Image(systemName: "mappin.square.fill")
                                    .accessibilityLabel(Text("compose.title.a11y.removeLocation", bundle: .module))
                            }
                        }

                        Button {
                            self.textModel.insertAtCursorPosition(content: "#")
                        } label: {
                            Image(systemName: "number")
                                .accessibilityLabel(Text("compose.title.a11y.addHashtag", bundle: .module))
                        }

                        Button {
                            self.textModel.insertAtCursorPosition(content: "@")
                        } label: {
                            Image(systemName: "at")
                                .accessibilityLabel(Text("compose.title.a11y.addMention", bundle: .module))
                        }
                    }
                }

                Spacer()

                Text("\(self.applicationState.statusMaxCharacters - textModel.text.string.utf16.count)")
                    .foregroundColor(.customGrayColor)
                    .font(.system(size: self.keyboardFontTextSize))
                    .accessibilityLabel("") // TODO: Add a11y label
            }
            .padding(8)
            .font(.system(size: self.keyboardFontImageSize))
        }
        .background(Color.keyboardToolbarColor)
    }

    private func placeholder() -> String {
        self.statusViewModel == nil ? NSLocalizedString("compose.title.attachPhotoFull", bundle: Bundle.module, comment: "") : NSLocalizedString("compose.title.attachPhotoMini", bundle: Bundle.module, comment: "")
    }

    private var hasChanges: Bool {
        guard let statusToEdit else { return true }

        let textChanged = textModel.text.string != (initialText ?? "")
        let sensitiveChanged = isSensitive != statusToEdit.sensitive
        let spoilerChanged = spoilerText != (statusToEdit.spoilerText ?? "")
        let placeChanged = place?.id != statusToEdit.place?.id
        let commentsChanged = commentsDisabled != statusToEdit.commentsDisabled
        let altChanged = existingAttachments.contains { attachment in
            attachment.description != (initialDescriptions[attachment.id] ?? nil)
        }

        return textChanged || sensitiveChanged || spoilerChanged || placeChanged || commentsChanged || altChanged
    }

    private func isPublishButtonDisabled() -> Bool {
        // When application is during uploading photos we cannot send new status.
        if self.photosAreUploading == true {
            return true
        }

        switch self.editMode {
        case .comment:
            // Editing a comment: text is required, photo is optional.
            if self.textModel.text.string.isEmpty { return true }
        case .photo:
            // Editing a photo post: disabled if nothing has changed.
            if !self.hasChanges { return true }
        case .none:
            // New status (not editing).
            // When status is not a comment, then photo is required.
            if self.statusViewModel == nil && self.photosAttachment.hasUploadedPhotos() == false {
                return true
            }
            // When status is a comment (reply), then text is required.
            if self.statusViewModel != nil && self.textModel.text.string.isEmpty {
                return true
            }
        }

        return false
    }

    private func isInteractiveDismissDisabled() -> Bool {
        if self.textModel.text.string.isEmpty == false {
            return true
        }

        if self.photosAreUploading == true {
            return true
        }

        if self.photosAttachment.hasUploadedPhotos() == true {
            return true
        }

        return false
    }

    private func processFiles(urls: [URL]) async {
        let items = urls.filter { $0.startAccessingSecurityScopedResource() }
            .compactMap { NSItemProvider(contentsOf: $0) }

        self.attachments.append(contentsOf: items)
        await self.loadPhotos()
    }

    private func loadPhotos() async {
        self.photosAreUploading = true
        self.publishDisabled = self.isPublishButtonDisabled()
        self.interactiveDismissDisabled = self.isInteractiveDismissDisabled()

        // We have to create list with existing photos.
        var temporaryPhotosAttachment: [PhotoAttachment] = []

        // Add to collection photos selected on photo picker.
        for item in self.selectedItems {
            if let photoAttachment = self.photosAttachment.first(where: { $0.photosPickerItem == item }) {
                temporaryPhotosAttachment.append(photoAttachment)
                continue
            }

            temporaryPhotosAttachment.append(PhotoAttachment(photosPickerItem: item))
        }

        // Add to collection photos from share sheet.
        for item in self.attachments {
            if let photoAttachment = self.photosAttachment.first(where: { $0.nsItemProvider == item }) {
                temporaryPhotosAttachment.append(photoAttachment)
                continue
            }

            temporaryPhotosAttachment.append(PhotoAttachment(nsItemProvider: item))
        }

        // Add to collection photos from camera picker.
        for item in self.images {
            if let photoAttachment = self.photosAttachment.first(where: { $0.uiImage == item }) {
                temporaryPhotosAttachment.append(photoAttachment)
                continue
            }

            temporaryPhotosAttachment.append(PhotoAttachment(uiImage: item))
        }

        // We can show new list on the screen.
        self.photosAttachment = temporaryPhotosAttachment

        // Now we have to get from photos images as JPEG.
        for photoAttachment in self.photosAttachment.filter({ $0.photoData == nil }) {
            do {
                try await photoAttachment.loadImage()
            } catch {
                photoAttachment.loadError = error

                if Bundle.main.bundlePath.hasSuffix(".appex") {
                    ErrorService.shared.handle(error, message: "compose.error.cannotLoadImageFromExternalLibrary")
                } else {
                    ErrorService.shared.handle(error, message: "compose.error.loadingPhotosFailed", showToastr: true)
                }
            }
        }

        // Open again the keyboard.
        self.focusedField = .content

        // Upload images which hasn't been uploaded yet.
        await self.upload()

        // Change state of the screen.
        self.photosAreUploading = false
        self.refreshScreenState()
    }

    private func refreshScreenState() {
        self.photosAreAttached = self.photosAttachment.hasUploadedPhotos()
        self.publishDisabled = self.isPublishButtonDisabled()
        self.interactiveDismissDisabled = self.isInteractiveDismissDisabled()
    }

    private func upload() async {
        for photoAttachment in self.photosAttachment {
            await self.onUpload(photoAttachment)
        }
    }

    private func close() {
        // Clean tmp folder from file transferred from Photos.
        self.photosAttachment.removeTmpFiles()

        // Close the view.
        self.onClose()
    }

    private func publishStatus() async {
        if self.applicationState.warnAboutMissingAlt == false {
            await self.sendToServer()
            return
        }

        // In edit mode, check existing attachments for missing alt texts.
        // In compose mode, check newly uploaded photos.
        let notAllImagesHaveAltText: Bool
        if self.statusToEdit != nil {
            notAllImagesHaveAltText = self.existingAttachments.contains(where: { ($0.description ?? "").isEmpty })
        } else {
            notAllImagesHaveAltText = self.photosAttachment.contains(where: { ($0.uploadedAttachment?.description ?? "").isEmpty })
        }

        if notAllImagesHaveAltText == false {
            await self.sendToServer()
            return
        }

        self.showAltAlert = true
    }

    private func sendToServer() async {
        do {
            let components = self.createStatus()

            if let statusToEdit {
                // Build components with existing media IDs so the server keeps the attachments.
                let existingMediaIds = statusToEdit.mediaAttachments.map { $0.id }
                let newMediaIds = self.photosAttachment.getUploadedPhotoIds()
                let allMediaIds = newMediaIds.isEmpty ? existingMediaIds : newMediaIds
                let editComponents = Pixelfed.Statuses.Components(
                    inReplyToId: nil,
                    text: components.text,
                    spoilerText: components.spoilerText,
                    mediaIds: allMediaIds,
                    visibility: components.visibility,
                    sensitive: components.sensitive,
                    place: self.place
                )
                if let status = try await self.client.statuses?.edit(statusId: statusToEdit.id, status: editComponents) {
                    // Update alt texts for attachments whose description changed.
                    for attachment in self.existingAttachments {
                        if attachment.description != (self.initialDescriptions[attachment.id] ?? nil) {
                            _ = try? await self.client.media?.update(
                                id: attachment.id,
                                description: attachment.description ?? "",
                                focus: nil
                            )
                        }
                    }

                    self.applicationState.latestPublishedStatusId = status.id
                    self.applicationState.showInteractionStatusId = String.empty()
                    ToastrService.shared.showSuccess("status.title.statusEdited", imageSystemName: "checkmark.circle.fill")
                    self.close()
                }
            } else {
                // Publish new status.
                if let status = try await self.client.statuses?.new(status: components) {
                    self.applicationState.latestPublishedStatusId = status.id
                    self.applicationState.showInteractionStatusId = String.empty()
                    self.close()
                }
            }
        } catch {
            // NOTE: An error 400 can be also for the 10-edits-max limitation from the API
            ErrorService.shared.handle(error, message: "compose.error.postingStatusFailed", bundle: Bundle.module, showToastr: true)
        }
    }

    private func createStatus() -> Pixelfed.Statuses.Components {
        return Pixelfed.Statuses.Components(inReplyToId: self.statusViewModel?.getOrginalStatusId(),
                                            text: self.textModel.text.string,
                                            spoilerText: self.isSensitive ? self.spoilerText : String.empty(),
                                            mediaIds: self.photosAttachment.getUploadedPhotoIds(),
                                            visibility: self.visibility,
                                            sensitive: self.isSensitive,
                                            placeId: self.place?.id,
                                            commentsDisabled: self.commentsDisabled)
    }
}
