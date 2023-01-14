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
        
    // Opacity usied during fadein/fadeoff animations.
    @State private var opacity = 0.6
    
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
                            .offset(x: currentOffset.width)
                            .scaleEffect(finalAmount + currentAmount)
                            .gesture((finalAmount + currentAmount) > 1.0 ? dragGesture : nil)
                            .gesture(magnificationGesture)
                            .gesture(doubleTapGesture)
                            .gesture(tapGesture)
                    }
                }
            }
            .opacity(self.opacity)
            .tabViewStyle(PageTabViewStyle())
            .overlay(alignment: .topTrailing, content: {
                Button {
                    self.close()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.mainTextColor.opacity(0.3))
                        .clipShape(Circle())
                        .padding()
                }
            })
        }
        .onAppear {
            withAnimation(.linear(duration: 0.2)) {
                opacity = 1.0
            }
        }
    }
    
    private func close() {
        withAnimation(.linear(duration: 0.3)) {
            opacity = 0.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withoutAnimation {
                dismiss()
            }
        }
    }
    
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { amount in
                currentAmount = amount - 1
            }
            .onEnded { amount in
                let finalMagnification = finalAmount + currentAmount
                
                if finalMagnification < 1.0 {
                    // When image is small we are returning to starting point.
                    withAnimation(.default) {
                        finalAmount = 1.0
                        currentAmount = 0
                        
                        // Also we have to move image to orginal position.
                        currentOffset = CGSize.zero
                    }
                } else if finalMagnification > 2.0 {
                    // When image is magnified to much we are rturning to 1.5 maginification.
                    withAnimation(.default) {
                        finalAmount = 1.5
                        currentAmount = 0
                    }
                } else {
                    finalAmount = finalMagnification
                    currentAmount = 0
                }
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
        DragGesture()
            .onChanged { amount in
                self.currentOffset = CGSize(width: amount.translation.width + self.accumulatedOffset.width,
                                            height: amount.translation.height + self.accumulatedOffset.height)
            } .onEnded { amount in
                self.currentOffset = CGSize(width: amount.translation.width + self.accumulatedOffset.width,
                                            height: amount.translation.height + self.accumulatedOffset.height)
                self.accumulatedOffset = self.currentOffset
            }
    }
    
    var tapGesture: some Gesture {
        TapGesture().onEnded({ _ in
            self.close()
        })
    }
}

struct ImagesViewer_Previews: PreviewProvider {
    static var previews: some View {
        Text("Cos")
        // ImagesViewer(statusViewModel: StatusViewModel())
    }
}
