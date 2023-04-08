//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

public struct FavouriteTouch: View {
    @State private var showThumb = 100
    @State private var showCircle = 0
    @State private var opacity = 1.0

    private let finished: () -> Void

    public init(finished: @escaping () -> Void) {
        self.finished = finished
    }

    public var body: some View {
        ZStack {
            Circle()
                .frame(width: 55, height: 55, alignment: .center)
                .foregroundColor(.white.opacity(0.75))
                .scaleEffect(CGFloat(showCircle))

            Image(systemName: "star.fill")
                .font(.system(size: 26))
                .foregroundColor(.black.opacity(0.4))
                .clipShape(Rectangle().offset(y: CGFloat(showThumb)))
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(Animation.interpolatingSpring(stiffness: 170, damping: 15)) {
                showCircle = 1
            }

            withAnimation(Animation.easeInOut(duration: 0.5).delay(0.25)) {
                showThumb = 0
            }

            withAnimation(Animation.easeInOut(duration: 0.5).delay(1.75)) {
                opacity = 0
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            self.finished()
        }
    }
}
