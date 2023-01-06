//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI

struct LoadingIndicator: View {
    var body: some View {
        ProgressView {
            Text("Loading...")
                .foregroundColor(.mainTextColor)
                .font(.caption2)
        }
        .progressViewStyle(CircularProgressViewStyle())
        .tint(.mainTextColor)
    }
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator()
    }
}
