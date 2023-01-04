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
    @ObservedObject public var statusData: StatusData
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                ImagesCarousel(attachments: statusData.attachments())

                VStack(alignment: .leading) {
                    NavigationLink(destination: UserProfileView(
                        accountId: statusData.accountId,
                        accountDisplayName: statusData.accountDisplayName,
                        accountUserName: statusData.accountUsername)
                        .environmentObject(applicationState)) {
                            UsernameRow(statusData: statusData)
                        }

                    HTMLFormattedText(statusData.content)
                        .padding(.leading, -4)
                    
                    VStack (alignment: .leading) {
                        LabelIcon(iconName: "camera", value: "SONY ILCE-7M3")
                        LabelIcon(iconName: "camera.aperture", value: "Viltrox 24mm F1.8 E")
                        LabelIcon(iconName: "timelapse", value: "24.0 mm, f/1.8, 1/640s, ISO 100")
                        LabelIcon(iconName: "calendar", value: "2 Oct 2022")
                    }
                    .foregroundColor(Color("LightGrayColor"))
                    
                    HStack {
                        Text("Uploaded")
                        Text(statusData.createdAt.toRelative(.isoDateTimeMilliSec))
                            .padding(.horizontal, -4)
                        if let applicationName = statusData.applicationName {
                            Text("via \(applicationName)")
                        }
                    }
                    .foregroundColor(Color("LightGrayColor"))
                    .font(.footnote)
                    
                    InteractionRow(statusData: statusData)
                        .padding(8)
                }
                .padding(8)
                
                Rectangle()
                    .size(width: UIScreen.main.bounds.width, height: 4)
                    .fill(Color("MainTextColor"))
                    .opacity(0.1)
                
                CommentsSection(statusId: statusData.id)
            }
        }
        .navigationBarTitle("Details")
        .onAppear {
            Task {
                do {
                    if let accountData = self.applicationState.accountData {
                        let timelineService = TimelineService()
                        _ = try await timelineService.updateStatus(statusData: self.statusData, and: accountData)
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
        DetailsView(statusData: StatusData())
    }
}
