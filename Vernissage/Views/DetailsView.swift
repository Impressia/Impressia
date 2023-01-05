//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonSwift
import AVFoundation

struct DetailsView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @State var statusId: String

    @State private var statusData: StatusData?
    
    var body: some View {
        ScrollView {
            if let statusData = self.statusData {
                VStack (alignment: .leading) {
                    ImagesCarousel(attachments: statusData.attachments())
                    
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
                            LabelIcon(iconName: "camera", value: "SONY ILCE-7M3")
                            LabelIcon(iconName: "camera.aperture", value: "Viltrox 24mm F1.8 E")
                            LabelIcon(iconName: "timelapse", value: "24.0 mm, f/1.8, 1/640s, ISO 100")
                            LabelIcon(iconName: "calendar", value: "2 Oct 2022")
                        }
                        .padding(.bottom, 2)
                        .foregroundColor(Color.lightGrayColor)
                        
                        HStack {
                            Text("Uploaded")
                            Text(statusData.createdAt.toRelative(.isoDateTimeMilliSec))
                                .padding(.horizontal, -4)
                            if let applicationName = statusData.applicationName {
                                Text("via \(applicationName)")
                            }
                        }
                        .foregroundColor(Color.lightGrayColor)
                        .font(.footnote)
                        
                        InteractionRow(statusData: statusData)
                            .padding(8)
                    }
                    .padding(8)
                                        
                    CommentsSection(statusId: statusData.id)
                }
            } else {
                VStack (alignment: .leading) {
                    Rectangle()
                        .fill(Color.placeholderText)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                        
                    VStack(alignment: .leading) {
                        UsernameRow(accountDisplayName: "Verylong Displayname",
                                    accountUsername: "@username")
                        
                        Text("Lorem ispum text something")
                            .foregroundColor(Color.lightGrayColor)
                            .font(.footnote)
                        Text("Lorem ispum text something sdf sdfsdf sdfdsfsdfsdf")
                            .foregroundColor(Color.lightGrayColor)
                            .font(.footnote)
                        
                        LabelIcon(iconName: "camera", value: "SONY ILCE-7M3")
                        LabelIcon(iconName: "camera.aperture", value: "Viltrox 24mm F1.8 E")
                        LabelIcon(iconName: "timelapse", value: "24.0 mm, f/1.8, 1/640s, ISO 100")
                        LabelIcon(iconName: "calendar", value: "2 Oct 2022")
                    }.padding(8)
                }
                .redacted(reason: .placeholder)
                .animatePlaceholder(isLoading: .constant(true))
            }
        }
        .navigationBarTitle("Details")
        .onAppear {
            Task {
                do {
                    // Get status from API.
                    let status = try await TimelineService.shared.getStatus(withId: self.statusId, and: self.applicationState.accountData)

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
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(statusId: "123")
    }
}
