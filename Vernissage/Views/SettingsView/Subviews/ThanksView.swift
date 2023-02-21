//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ThanksView: View {
    @EnvironmentObject var routerPath: RouterPath
        
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Group {
                    Text("Thank you 💕")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.viewTextColor)
                        .padding(.top, 8)
                    Text("Thanks for your purchase. Purchases both big and small help us keep our dream of providing the best quality products to our customers. We hope you’re loving Vernissage.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.viewTextColor)
                    
                    Button("Close") {
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
