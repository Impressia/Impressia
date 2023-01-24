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
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.lightGrayColor)
                        .clipShape(AvatarShape.circle.shape())
                        .background(
                            AvatarShape.circle.shape()
                        )
                    
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
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.lightGrayColor)
                        .clipShape(AvatarShape.roundedRectangle.shape())
                        .background(
                            AvatarShape.roundedRectangle.shape()
                        )
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
