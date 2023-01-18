//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonKit
import AVFoundation

struct StatusView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.dismiss) private var dismiss

    @State var statusId: String
    @State var imageBlurhash: String?
    @State var imageWidth: Int32?
    @State var imageHeight: Int32?

    @State private var messageForStatus: StatusViewModel?
    @State private var showCompose = false
    @State private var showImageViewer = false
    @State private var firstLoadFinished = false
    
    @State private var statusViewModel: StatusViewModel?
    
    @State private var selectedAttachmentId: String?
    @State private var exifCamera: String?
    @State private var exifExposure: String?
    @State private var exifCreatedDate: String?
    @State private var exifLens: String?
        
    var body: some View {
        ScrollView {
            if let statusViewModel = self.statusViewModel {
                VStack (alignment: .leading) {                    
                    ImagesCarousel(attachments: statusViewModel.mediaAttachments,
                                   selectedAttachmentId: $selectedAttachmentId,
                                   exifCamera: $exifCamera,
                                   exifExposure: $exifExposure,
                                   exifCreatedDate: $exifCreatedDate,
                                   exifLens: $exifLens)
                    .onTapGesture {
                        // withoutAnimation {
                            self.showImageViewer.toggle()
                        // }
                    }
                    
                    VStack(alignment: .leading) {
                        NavigationLink(destination: UserProfileView(
                            accountId: statusViewModel.account.id,
                            accountDisplayName: statusViewModel.account.displayName,
                            accountUserName: statusViewModel.account.username)
                            .environmentObject(applicationState)) {
                                UsernameRow(accountId: statusViewModel.account.id,
                                            accountAvatar: statusViewModel.account.avatar,
                                            accountDisplayName: statusViewModel.account.displayNameWithoutEmojis,
                                            accountUsername: statusViewModel.account.username)
                            }
                        
                        HTMLFormattedText(statusViewModel.content)
                            .padding(.leading, -4)
                        
                        VStack (alignment: .leading) {
                            if let name = statusViewModel.place?.name, let country = statusViewModel.place?.country {
                                LabelIcon(iconName: "mappin.and.ellipse", value: "\(name), \(country)")
                            }
                            
                            LabelIcon(iconName: "camera", value: self.exifCamera)
                            LabelIcon(iconName: "camera.aperture", value: self.exifLens)
                            LabelIcon(iconName: "timelapse", value: self.exifExposure)
                            LabelIcon(iconName: "calendar", value: self.exifCreatedDate?.toDate(.isoDateTimeSec)?.formatted())
                        }
                        .padding(.bottom, 2)
                        .foregroundColor(.lightGrayColor)
                        
                        HStack {
                            Text("Uploaded")
                            Text(statusViewModel.createdAt.toRelative(.isoDateTimeMilliSec))
                                .padding(.horizontal, -4)
                            if let applicationName = statusViewModel.application?.name {
                                Text("via \(applicationName)")
                            }
                        }
                        .foregroundColor(.lightGrayColor)
                        .font(.footnote)
                        
                        InteractionRow(statusViewModel: statusViewModel) {
                            self.messageForStatus = statusViewModel
                            self.showCompose.toggle()
                        }
                        .foregroundColor(.accentColor)
                        .padding(8)
                    }
                    .padding(8)
                                        
                    CommentsSection(statusId: statusViewModel.id) { messageForStatus in
                        self.messageForStatus = messageForStatus
                        self.showCompose.toggle()
                    }
                }
            } else {
                StatusPlaceholder(imageHeight: self.getImageHeight(), imageBlurhash: self.imageBlurhash)
            }
        }
        .navigationBarTitle("Details")
        .sheet(isPresented: $showCompose, content: {
            ComposeView(statusViewModel: $messageForStatus)
        })
        .fullScreenCover(isPresented: $showImageViewer, content: {
            if let statusViewModel = self.statusViewModel {
                ImagesViewer(statusViewModel: statusViewModel, selectedAttachmentId: selectedAttachmentId ?? String.empty())
            }
        })
        .task {
            do {
                guard firstLoadFinished == false else {
                    return
                }
                
                // Get status from API.
                if let status = try await StatusService.shared.getStatus(withId: self.statusId, and: self.applicationState.accountData) {
                    let statusViewModel = StatusViewModel(status: status)
                    
                    // Download images and recalculate exif data.
                    let allImages = await TimelineService.shared.fetchAllImages(statuses: [status])
                    for attachment in statusViewModel.mediaAttachments {
                        if let data = allImages[attachment.id] {
                            attachment.set(data: data)
                        }
                    }
                    
                    self.statusViewModel = statusViewModel
                    self.selectedAttachmentId = statusViewModel.mediaAttachments.first?.id ?? String.empty()
                    self.firstLoadFinished = true
                    
                    // If we have status in database then we can update data.
                    if let accountData = self.applicationState.accountData,
                       let statusDataFromDatabase = StatusDataHandler.shared.getStatusData(accountId: accountData.id, statusId: self.statusId) {
                        _ = try await TimelineService.shared.updateStatus(statusDataFromDatabase, accountData: accountData, basedOn: status)
                    }
                }
            } catch NetworkError.notSuccessResponse(let response) {
                if response.statusCode() == HTTPStatusCode.notFound, let accountId = self.applicationState.accountData?.id {
                    StatusDataHandler.shared.remove(accountId: accountId, statusId: self.statusId)
                    ErrorService.shared.handle(NetworkError.notSuccessResponse(response), message: "Status not existing anymore.", showToastr: true)
                    dismiss()
                }
            }
            catch {
                ErrorService.shared.handle(error, message: "Error during download status from server.", showToastr: true)
            }
        }
    }
    
    private func setAttachment(_ attachmentData: AttachmentData) {
        exifCamera = attachmentData.exifCamera
        exifExposure = attachmentData.exifExposure
        exifCreatedDate = attachmentData.exifCreatedDate
        exifLens = attachmentData.exifLens
    }
    
    private func getImageHeight() -> Double {
        if let imageHeight = self.imageHeight, let imageWidth = self.imageWidth, imageHeight > 0 && imageWidth > 0 {
            return self.calculateHeight(width: Double(imageWidth), height: Double(imageHeight))
        }
        
        // If we don't have image height and width in metadata, we have to use some constant height.
        return UIScreen.main.bounds.width * 0.75
    }
    
    private func calculateHeight(width: Double, height: Double) -> CGFloat {
        let divider = width / UIScreen.main.bounds.size.width
        return height / divider
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(statusId: "123")
    }
}
