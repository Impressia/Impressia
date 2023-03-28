//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import SwiftUI

struct ContentWarning<Content: View>: View {
    private let blurhash: String?
    private let spoilerText: String?
    private let content: Content
    
    @State private var showSensitive = false
    
    init(blurhash: String?, spoilerText: String?, @ViewBuilder content: () -> Content) {
        self.blurhash = blurhash
        self.spoilerText = spoilerText
        self.content = content()
    }
    
    var body: some View {
        if self.showSensitive {
            ZStack {
                content
                    .transition(.opacity)
                VStack(alignment: .trailing) {
                    HStack(alignment: .top) {
                        Spacer()
                        Button {
                            withAnimation {
                                self.showSensitive = false
                            }
                        } label: {
                            Image(systemName: "eye.slash")
                                .font(.title2)
                                .shadow(color: Color.systemBackground, radius: 0.3)
                        }.padding()
                    }
                    Spacer()
                }
                .foregroundColor(.mainTextColor)
            }
        } else {
            ZStack {
                BlurredImage(blurhash: blurhash)
                VStack(alignment: .center) {
                    Spacer()
                    Image(systemName: "eye.slash.fill")
                        .font(.title2)
                        .shadow(color: Color.systemBackground, radius: 0.3)
                    Text("global.title.contentWarning", comment: "Sensitive content")
                        .font(.title2)
                        .shadow(color: Color.systemBackground, radius: 0.3)
                    if let spoilerText {
                        Text(spoilerText)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.systemBackground, radius: 0.3)
                    }
                    Button {
                        withAnimation {
                            self.showSensitive = true
                        }
                    } label: {
                        Text("global.title.seePost", comment: "See post")
                            .shadow(color: Color.systemBackground, radius: 0.3)
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                }
                .foregroundColor(.mainTextColor)
            }
            .transition(.opacity)
        }
    }
}

struct ContentWarning_Previews: PreviewProvider {
    static var previews: some View {
        ContentWarning(blurhash: nil, spoilerText: "Spoiler") {
            Image(systemName: "people")
        }
    }
}
