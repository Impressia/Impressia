//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ImagesViewer: View {
    @State var statusViewModel: StatusViewModel
    @State var visible = false
    @Environment(\.dismiss) private var dismiss
        
    // Zoom.
    @State var zoomScale = 1.0
    
    // Magnification.
    @State private var currentAmount = 0.0
    @State private var finalAmount = 1.0
    
    // Draging.
    @State private var currentOffset = CGSize.zero
        
    var body: some View {
        ZStack {
            if self.visible {
                TabView() {
                    ForEach(statusViewModel.mediaAttachments, id: \.id) { attachment in
                        if let data = attachment.data, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .tag(attachment.id)
                                .offset(currentOffset)
                                .scaleEffect((finalAmount + currentAmount) < 1.0 ? 1.0 : (finalAmount + currentAmount))
                                .gesture((finalAmount + currentAmount) > 1.0 ? dragGesture : nil)
                                .gesture(magnificationGesture)
                                .gesture(doubleTapGesture)
                                .gesture(tapGesture)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .overlay(alignment: .topTrailing, content: {
                    Button {
                        self.close()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Circle())
                    }
                })
            }
        }
        .onAppear {
            withAnimation(.easeInOut) {
                self.visible = true
            }
        }
    }
    
    private func close() {
        withAnimation(.easeInOut) {
            self.visible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
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
                finalAmount += currentAmount
                currentAmount = 0
            }
    }
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                currentOffset = CGSize.zero
                currentAmount = 0
                finalAmount = 1.0
            }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { amount in
                self.currentOffset = amount.translation
            } .onEnded { amount in
                if (finalAmount + currentAmount) == 1.0 {
                    withAnimation(.linear) {
                        currentOffset = CGSize.zero
                    }
                }
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
