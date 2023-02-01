//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit
import NukeUI

struct InstanceRow: View {
    private let instance: Instance
    private let action: (String) -> Void
    
    public init(instance: Instance, action: @escaping (String) -> Void) {
        self.instance = instance
        self.action = action
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                LazyImage(url: instance.thumbnail) { state in
                    if let image = state.image {
                        image
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .aspectRatio(contentMode: .fit)
                    } else if state.isLoading {
                        placeholderView
                    } else {
                        placeholderView
                    }
                }
                .priority(.high)
                .frame(width: 50, height: 50)
            
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(instance.title ?? "")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(instance.uri)
                            .font(.subheadline)
                    }
                    
                    Spacer()

                    Button("Sign in") {
                        self.action(instance.uri)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 4)
                }
            }
            
            Text(instance.description ?? "")
                .font(.caption)
        }
    }
    
    @ViewBuilder private var placeholderView: some View {
        Image("PixelfedInstance")
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
    }
}
