//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonSwift
import AVFoundation

struct DetailsView: View {
    @State public var statusData: StatusData
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                ImagesCarousel(attachments: statusData.attachments())

                VStack(alignment: .leading) {
                    UsernameRow(statusData: statusData)
                    HTMLFormattedText(statusData.content)
                        .padding(.leading, -4)
                    
                    VStack (alignment: .leading) {
                        LabelIcon(iconName: "camera", value: "SONY ILCE-7M3")
                        LabelIcon(iconName: "camera.aperture", value: "Viltrox 24mm F1.8 E")
                        LabelIcon(iconName: "timelapse", value: "24.0 mm, f/1.8, 1/640s, ISO 100")
                        LabelIcon(iconName: "calendar", value: "2 Oct 2022")
                    }
                    .foregroundColor(Color("lightGrayColor"))
                    
                    HStack {
                        Text("Uploaded")
                        Text(statusData.createdAt.toDate(.isoDateTimeMilliSec) ?? Date(), style: .relative)
                            .padding(.horizontal, -4)
                        Text("ago")
                        if let applicationName = statusData.applicationName {
                            Text("via \(applicationName)")
                                .padding(.horizontal, -4)
                        }
                    }
                    .foregroundColor(Color("lightGrayColor"))
                    .font(.footnote)
                    
                    InteractionRow(statusData: statusData)
                }
                .padding(8)
                
                if statusData.repliesCount > 0 {
                    HStack (alignment: .center) {
                        Image(systemName: "message")
                            .padding(.leading, 8)
                            .padding(.vertical, 8)
                        Text("\(statusData.repliesCount) replies")
                        Spacer()
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .background(Color("mainTextColor").opacity(0.05))
                    .foregroundColor(Color("lightGrayColor"))
                    
                    CommentsSection(statusId: statusData.id)
                }
            }
        }
        .navigationBarTitle("Details")
        .onAppear {
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(statusData: StatusData())
    }
}
