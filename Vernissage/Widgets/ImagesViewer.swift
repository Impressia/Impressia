//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ImagesViewer: View {
    @State var statusViewModel: StatusModel
    @State var selectedAttachmentId: String = String.empty()
    @Environment(\.dismiss) private var dismiss
        
    private let closeDragDistance = 100.0
    
    // Opacity usied during close dialog animation.
    @State private var opacity = 1.0
    
    // Zoom.
    @State private var zoomScale = 1.0
    
    // Magnification.
    @State private var currentMagnification = 0.0
    @State private var finalMagnification = 1.0
    
    // Rotation.
    @State private var rotationAngle = Angle.zero
    
    // Draging.
    @State private var currentOffset = CGSize.zero
    @State private var accumulatedOffset = CGSize.zero
        
    var body: some View {
        if let attachment = self.statusViewModel.mediaAttachments.first(where: { $0.id == self.selectedAttachmentId }),
           let data = attachment.data,
           let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .tag(attachment.id)
                .offset(currentOffset)
                .rotationEffect(rotationAngle)
                .scaleEffect(finalMagnification + currentMagnification)
                .opacity(self.opacity)
                .gesture(dragGesture)
                .gesture(magnificationGesture)
                .gesture(doubleTapGesture)
                .gesture(tapGesture)
        }
    }
    
    private func close() {
        withoutAnimation {
            dismiss()
        }
    }
    
    @MainActor
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { amount in
                currentMagnification = (amount - 1) * self.finalMagnification
            }
            .onEnded { amount in
                let finalMagnification = finalMagnification + currentMagnification
                self.revertToPrecalculatedMagnification(magnification: finalMagnification)
            }
    }
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                withAnimation {
                    if self.finalMagnification == 1.0 {
                        currentOffset = CGSize.zero
                        accumulatedOffset = CGSize.zero
                        currentMagnification = 0
                        finalMagnification = 2.0
                    } else {
                        currentOffset = CGSize.zero
                        accumulatedOffset = CGSize.zero
                        currentMagnification = 0
                        finalMagnification = 1.0
                    }
                }
            }
    }
    
    @MainActor
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { amount in
                // Opacity and rotation is working only when we have small image size.
                if self.finalMagnification == 1.0 {
                    // We can move image whatever we want.
                    self.currentOffset = CGSize(width: amount.translation.width + self.accumulatedOffset.width,
                                                height: amount.translation.height + self.accumulatedOffset.height)
                    
                    // Changing opacity when we want to close.
                    let pictureOpacity = (self.closeDragDistance - self.currentOffset.height) / self.closeDragDistance
                    self.opacity = pictureOpacity >= 0 ? pictureOpacity : 0
                    
                    // Changing angle.
                    self.rotationAngle = Angle(degrees: Double(self.currentOffset.width / 30))
                } else {
                    // Bigger images we can move only horizontally (we have to include magnifications).
                    let offsetWidth = (amount.translation.width / self.finalMagnification) + self.accumulatedOffset.width
                    self.currentOffset = CGSize(width: offsetWidth, height: 0)
                }
            } .onEnded { amount in
                self.accumulatedOffset = CGSize(width: amount.translation.width + self.accumulatedOffset.width,
                                                height: amount.translation.height + self.accumulatedOffset.height)
                
                // Animations only for small images sizes,
                if self.finalMagnification == 1.0 {
                    if self.accumulatedOffset.height < closeDragDistance {
                        // Revert back image offset.
                        withAnimation(.easeInOut) {
                            self.currentOffset = CGSize.zero
                            self.accumulatedOffset = CGSize.zero
                            self.opacity = 1.0
                        }
                    } else {
                        // Close the screen.
                        withAnimation(.easeInOut) {
                            self.currentOffset = amount.predictedEndTranslation
                            self.accumulatedOffset = CGSize.zero
                            self.opacity = 1.0
                        }
                        
                        self.close()
                    }
                } else {
                    self.moveToEdge()
                }
                
                self.rotationAngle = Angle.zero
            }
    }
    
    var tapGesture: some Gesture {
        TapGesture().onEnded({ _ in
            self.close()
        })
    }
    
    @MainActor
    private func revertToPrecalculatedMagnification(magnification: Double) {
        if magnification < 1.0 {
            // When image is small we are returning to starting point.
            withAnimation(.default) {
                finalMagnification = 1.0
                currentMagnification = 0
                
                // Also we have to move image to orginal position.
                currentOffset = CGSize.zero
            }
            
            HapticService.shared.fireHaptic(of: .animation)
        } else if magnification > 3.0 {
            // When image is magnified to much we are rturning to 1.5 maginification.
            withAnimation(.default) {
                finalMagnification = 3.0
                currentMagnification = 0
            }
            
            HapticService.shared.fireHaptic(of: .animation)
        } else {
            finalMagnification = magnification
            currentMagnification = 0

            self.moveToEdge()
        }
    }
    
    @MainActor
    private func moveToEdge() {
        let maxEdgeDistance = ((UIScreen.main.bounds.width * self.finalMagnification) - UIScreen.main.bounds.width) / (2 * self.finalMagnification)
        
        if self.currentOffset.width > maxEdgeDistance {
            self.currentOffset = CGSize(width: maxEdgeDistance, height: 0)
            self.accumulatedOffset = self.currentOffset

            HapticService.shared.fireHaptic(of: .animation)
        } else if self.currentOffset.width < -maxEdgeDistance {
            self.currentOffset = CGSize(width: -maxEdgeDistance, height: 0)
            self.accumulatedOffset = self.currentOffset
            
            HapticService.shared.fireHaptic(of: .animation)
        }
    }
}
