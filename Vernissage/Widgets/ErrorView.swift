//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct ErrorView: View {
    public var error: Error
    public var refreshAction: (() async -> Void)?
        
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .foregroundColor(.accentColor)
                .frame(width: 64, height: 64, alignment: .center)
                
            Text("\(error.localizedDescription)")
                .multilineTextAlignment(.center)

            if let refreshAction {
                Button {
                    Task {
                        await refreshAction()
                    }
                } label: {
                    Text("global.title.refresh", comment: "Refresh")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
