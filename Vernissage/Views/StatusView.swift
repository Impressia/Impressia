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
    @State var statusId: String
    @State var imageBlurhash: String?
    @State var imageWidth: Int32?
    @State var imageHeight: Int32?

    @State private var messageForStatus: Status?
    @State private var showCompose = false
    
    @State private var statusData: StatusData?
    @State private var status: Status?
    
    @State private var exifCamera: String?
    @State private var exifExposure: String?
    @State private var exifCreatedDate: String?
    @State private var exifLens: String?
    
    var body: some View {
        ScrollView {
            if let statusData = self.statusData, let status = self.status {
                VStack (alignment: .leading) {                    
                    ImagesCarousel(attachments: statusData.attachments(),
                                   exifCamera: $exifCamera,
                                   exifExposure: $exifExposure,
                                   exifCreatedDate: $exifCreatedDate,
                                   exifLens: $exifLens)
                    
                    VStack(alignment: .leading) {
                        NavigationLink(destination: UserProfileView(
                            accountId: statusData.accountId,
                            accountDisplayName: statusData.accountDisplayName,
                            accountUserName: statusData.accountUsername)
                            .environmentObject(applicationState)) {
                                UsernameRow(accountAvatar: statusData.accountAvatar,
                                            accountDisplayName: statusData.accountDisplayName,
                                            accountUsername: statusData.accountUsername)
                            }
                        
                        HTMLFormattedText(statusData.content)
                            .padding(.leading, -4)
                        
                        VStack (alignment: .leading) {
                            LabelIcon(iconName: "camera", value: self.exifCamera)
                            LabelIcon(iconName: "camera.aperture", value: self.exifLens)
                            LabelIcon(iconName: "timelapse", value: self.exifExposure)
                            LabelIcon(iconName: "calendar", value: self.exifCreatedDate?.toDate(.isoDateTimeSec)?.formatted())
                        }
                        .padding(.bottom, 2)
                        .foregroundColor(.lightGrayColor)
                        
                        HStack {
                            Text("Uploaded")
                            Text(statusData.createdAt.toRelative(.isoDateTimeMilliSec))
                                .padding(.horizontal, -4)
                            if let applicationName = statusData.applicationName {
                                Text("via \(applicationName)")
                            }
                        }
                        .foregroundColor(.lightGrayColor)
                        .font(.footnote)
                        
                        InteractionRow(status: status) {
                            self.messageForStatus = status
                            self.showCompose.toggle()
                        }
                        .foregroundColor(.accentColor)
                        .padding(8)
                    }
                    .padding(8)
                                        
                    CommentsSection(statusId: statusData.id) { messageForStatus in
                        self.messageForStatus = messageForStatus
                        self.showCompose.toggle()
                    }
                }
            } else {
                VStack (alignment: .leading) {
                    if let imageBlurhash, let uiImage = UIImage(blurHash: imageBlurhash, size: CGSize(width: 32, height: 32)) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width, height: self.getImageHeight())
                    } else {
                        Rectangle()
                            .fill(Color.placeholderText)
                            .frame(width: UIScreen.main.bounds.width, height: self.getImageHeight())
                            .redacted(reason: .placeholder)
                    }
                    
                    VStack(alignment: .leading) {
                        UsernameRow(accountDisplayName: "Verylong Displayname",
                                    accountUsername: "@username")
                        
                        Text("Lorem ispum text something")
                            .foregroundColor(.lightGrayColor)
                            .font(.footnote)
                        Text("Lorem ispum text something sdf sdfsdf sdfdsfsdfsdf")
                            .foregroundColor(.lightGrayColor)
                            .font(.footnote)
                        
                        LabelIcon(iconName: "camera", value: "SONY ILCE-7M3")
                        LabelIcon(iconName: "camera.aperture", value: "Viltrox 24mm F1.8 E")
                        LabelIcon(iconName: "timelapse", value: "24.0 mm, f/1.8, 1/640s, ISO 100")
                        LabelIcon(iconName: "calendar", value: "2 Oct 2022")
                    }
                    .padding(8)
                    .redacted(reason: .placeholder)
                    .animatePlaceholder(isLoading: .constant(true))
                }
            }
        }
        .navigationBarTitle("Details")
        .sheet(isPresented: $showCompose, content: {
            ComposeView(status: $messageForStatus)
        })
        .onAppear {
            Task {
                do {
                    // Get status from API.
                    self.status = try await TimelineService.shared.getStatus(withId: self.statusId, and: self.applicationState.accountData)

                    if let status {
                        // Get status from database.
                        let statusDataFromDatabase = StatusDataHandler.shared.getStatusData(statusId: self.statusId)
                        
                        // If we have status in database then we can update data.
                        if let statusDataFromDatabase {
                            self.statusData = try await TimelineService.shared.updateStatus(statusDataFromDatabase, basedOn: status)
                        } else {
                            self.statusData = try await status.createStatusData()
                        }
                    }
                } catch {
                    print("Error \(error.localizedDescription)")
                }
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
