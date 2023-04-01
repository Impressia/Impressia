//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

struct AvatarShapesSectionView: View {
    @EnvironmentObject var applicationState: ApplicationState

    var body: some View {
        Section("settings.title.avatar") {
            Button {
                self.applicationState.avatarShape = .circle
                ApplicationSettingsHandler.shared.set(avatarShape: .circle)
            } label: {
                HStack {
                    Image("Avatar")
                        .resizable()
                        .clipShape(AvatarShape.circle.shape())
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)

                    Text("settings.title.circle", comment: "Circle")
                        .foregroundColor(.label)
                    Spacer()

                    if self.applicationState.avatarShape == .circle {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .padding(.vertical, 4)

            Button {
                self.applicationState.avatarShape = .roundedRectangle
                ApplicationSettingsHandler.shared.set(avatarShape: .roundedRectangle)
            } label: {
                HStack {
                    Image("Avatar")
                        .resizable()
                        .clipShape(AvatarShape.roundedRectangle.shape())
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)

                    Text("settings.title.rounderRectangle", comment: "Rounded rectangle")
                        .foregroundColor(.label)
                    Spacer()

                    if self.applicationState.avatarShape == .roundedRectangle {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
