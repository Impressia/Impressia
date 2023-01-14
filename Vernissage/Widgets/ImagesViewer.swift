//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ImagesViewer: View {
    @State var statusViewModel: StatusViewModel
    @State var selectedAttachmentId: String = String.empty()
    @Environment(\.dismiss) private var dismiss
        
    // Opacity usied during close dialog animation.
    @State private var opacity = 1.0
    private let closeDragDistance = 140.0
    
    // Zoom.
    @State private var zoomScale = 1.0
    
    // Magnification.
    @State private var currentAmount = 0.0
    @State private var finalAmount = 1.0
    
    // Draging.
    @State private var currentOffset = CGSize.zero
    @State private var accumulatedOffset = CGSize.zero
        
    var body: some View {
        ZStack {
            TabView(selection: $selectedAttachmentId) {
                ForEach(statusViewModel.mediaAttachments, id: \.id) { attachment in
                    if let data = attachment.data, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .tag(attachment.id)
                            .offset(currentOffset)
                            .scaleEffect(finalAmount + currentAmount)
                            .opacity(self.opacity)
                            //.gesture((finalAmount + currentAmount) > 1.0 ? dragGesture : nil)
                            .gesture(dragGesture)
                            .gesture(magnificationGesture)
                            .gesture(doubleTapGesture)
                            .gesture(tapGesture)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
    
    private func close() {
        dismiss()
    }
    
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { amount in
                currentAmount = amount - 1
            }
            .onEnded { amount in
                let finalMagnification = finalAmount + currentAmount
                // self.revertToPrecalculatedMagnification(magnification: finalMagnification)
                self.resetMagnification(magnification: finalMagnification)
            }
    }
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                withAnimation {
                    currentOffset = CGSize.zero
                    currentAmount = 0
                    finalAmount = 1.0
                }
            }
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance:20)
            .onChanged { amount in
                self.currentOffset = CGSize(width: amount.translation.width + self.accumulatedOffset.width,
                                            height: amount.translation.height + self.accumulatedOffset.height)
                
                let pictureOpacity = (self.closeDragDistance - self.currentOffset.height) / self.closeDragDistance
                self.opacity = pictureOpacity >= 0 ? pictureOpacity : 0
            } .onEnded { amount in
                self.currentOffset = CGSize(width: amount.translation.width + self.accumulatedOffset.width,
                                            height: amount.translation.height + self.accumulatedOffset.height)
                self.accumulatedOffset = self.currentOffset
                
                if self.accumulatedOffset.height < self.closeDragDistance {
                    withAnimation(.default) {
                        self.currentOffset = CGSize.zero
                        self.accumulatedOffset = CGSize.zero
                        self.opacity = 1.0
                    }
                } else {
                    self.close()
                }
            }
    }
    
    var tapGesture: some Gesture {
        TapGesture().onEnded({ _ in
            self.close()
        })
    }
    
    private func revertToPrecalculatedMagnification(magnification: Double) {
        if magnification < 1.0 {
            // When image is small we are returning to starting point.
            withAnimation(.default) {
                finalAmount = 1.0
                currentAmount = 0
                
                // Also we have to move image to orginal position.
                currentOffset = CGSize.zero
            }
        } else if magnification > 2.0 {
            // When image is magnified to much we are rturning to 1.5 maginification.
            withAnimation(.default) {
                finalAmount = 1.5
                currentAmount = 0
            }
        } else {
            finalAmount = magnification
            currentAmount = 0
        }
    }
    
    private func resetMagnification(magnification: Double) {
        withAnimation(.default) {
            finalAmount = 1.0
            currentAmount = 0
        }
    }
}

struct ImagesViewer_Previews: PreviewProvider {
    static var previews: some View {
        Text("Cos")
        // ImagesViewer(statusViewModel: StatusViewModel())
    }
}
