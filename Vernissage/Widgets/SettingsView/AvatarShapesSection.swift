//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI

struct AvatarShapesSection: View {
    @EnvironmentObject var applicationState: ApplicationState

    var body: some View {
        Section("Avatar") {
            Button {
                self.applicationState.avatarShape = .circle
                ApplicationSettingsHandler.shared.setDefaultAvatarShape(avatarShape: .circle)
            } label: {
                HStack {
                    Image("Avatar")
                        .resizable()
                        .clipShape(AvatarShape.circle.shape())
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                    
                    Text("Circle")
                        .foregroundColor(.label)
                    Spacer()
                    
                    if self.applicationState.avatarShape == .circle {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Button {
                self.applicationState.avatarShape = .roundedRectangle
                ApplicationSettingsHandler.shared.setDefaultAvatarShape(avatarShape: .roundedRectangle)
            } label: {
                HStack {
                    Image("Avatar")
                        .resizable()
                        .clipShape(AvatarShape.roundedRectangle.shape())
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)

                    Text("Rounded rectangle")
                        .foregroundColor(.label)
                    Spacer()
                    
                    if self.applicationState.avatarShape == .roundedRectangle {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}
