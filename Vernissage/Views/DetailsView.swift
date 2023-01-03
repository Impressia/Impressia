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
                    }
                    .foregroundColor(Color("lightGrayColor"))
                    .font(.footnote)
                    
                    InteractionRow(statusData: statusData)
                }
                .padding(8)
                
                CommentsSection(statusId: statusData.id)
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
