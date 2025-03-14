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
    @State private var isSensitive = false
    @State private var spoilerText = ""
    @State private var commentsDisabled = false
    @State private var place: Place?

    @State private var photosAreAttached = false
    @State private var publishDisabled = true
    @State private var interactiveDismissDisabled = false

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
    @State private var photosAttachment: [PhotoAttachment] = []

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
    enum SheetType: Identifiable {
        case photoDetails(PhotoAttachment)
        case placeSelector

        public var id: String {
            switch self {
            case .photoDetails:
                return "photoDetails"
            case .placeSelector:
                return "placeSelector"
            }
        }
    }

    private let statusViewModel: StatusModel?
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
        self.attachments = attachments
        self.onClose = onClose
        self.onUpload = onUpload
        self.draggedItem = nil

        self._textModel = .init(initialValue: .init())
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await self.publishStatus()
                    }
                } label: {
                    Text("compose.title.publish", bundle: Bundle.module, comment: "Publish")
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
            Task {
                await self.loadPhotos()
            }
        }
        .onChange(of: self.textModel.text) {
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

                // Grid with images.
                self.imagesGridView()

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

            Spacer()

            if let name = self.place?.name, let country = self.place?.country {
                Group {
                    Image(systemName: "mappin.and.ellipse")
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
                        }

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
                            Image(systemName: self.isSensitive ? "exclamationmark.square.fill" : "exclamationmark.square")
                        }

                        Button {
                            withAnimation(.easeInOut) {
                                self.commentsDisabled.toggle()
                            }
                        } label: {
                            Image(systemName: self.commentsDisabled ? "person.2.slash" : "person.2.fill")
                        }

                        Button {
                            if self.place != nil {
                                withAnimation(.easeInOut) {
                                    self.place = nil
                                }
                            } else {
                                self.showSheet = .placeSelector
                            }
                        } label: {
                            Image(systemName: self.place == nil ? "mappin.square" : "mappin.square.fill")
                        }

                        Button {
                            self.textModel.insertAtCursorPosition(content: "#")
                        } label: {
                            Image(systemName: "number")
                        }

                        Button {
                            self.textModel.insertAtCursorPosition(content: "@")
                        } label: {
                            Image(systemName: "at")
                        }
                    }
                }

                Spacer()

                Text("\(self.applicationState.statusMaxCharacters - textModel.text.string.utf16.count)")
                    .foregroundColor(.customGrayColor)
                    .font(.system(size: self.keyboardFontTextSize))
            }
            .padding(8)
            .font(.system(size: self.keyboardFontImageSize))
        }
        .background(Color.keyboardToolbarColor)
    }

    private func placeholder() -> String {
        self.statusViewModel == nil ? NSLocalizedString("compose.title.attachPhotoFull", bundle: Bundle.module, comment: "") : NSLocalizedString("compose.title.attachPhotoMini", bundle: Bundle.module, comment: "")
    }

    private func isPublishButtonDisabled() -> Bool {
        // When application is during uploading photos we cannot send new status.
        if self.photosAreUploading == true {
            return true
        }

        // When status is not a comment, then photo is required.
        if self.statusViewModel == nil && self.photosAttachment.hasUploadedPhotos() == false {
            return true
        }
        
        // When status is a comment, then text is required.
        if self.statusViewModel != nil && self.textModel.text.string.isEmpty {
            return true
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

        let notAllImagesHaveAltText = self.photosAttachment.contains(where: { ($0.uploadedAttachment?.description ?? "").isEmpty })
        if notAllImagesHaveAltText == false {
            await self.sendToServer()
            return
        }

        self.showAltAlert = true
    }

    private func sendToServer() async {
        do {
            let status = self.createStatus()
            if let status = try await self.client.statuses?.new(status: status) {
                print("Status: \(status.id)")
                self.applicationState.latestPublishedStatusId = status.id
                self.applicationState.showInteractionStatusId = String.empty()

                self.close()
            }
        } catch {
            ErrorService.shared.handle(error, message: "compose.error.postingStatusFailed", showToastr: true)
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
