//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

struct ThanksView: View {
    @EnvironmentObject var routerPath: RouterPath
        
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Group {
                    Text("settings.title.thankYouTitle", comment: "Thank you 💕")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.viewTextColor)
                        .padding(.top, 8)
                    Text("settings.title.thankYouMessage", comment: "Thank you message")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.viewTextColor)
                    
                    Button(NSLocalizedString("settings.title.thankYouClose", comment: "Close")) {
                        HapticService.shared.fireHaptic(of: .buttonPress)

                        withAnimation(.spring()) {
                            self.routerPath.presentedOverlay = nil
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }.padding(8)
            }
            .background(Color.viewBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(8)
    }
}
