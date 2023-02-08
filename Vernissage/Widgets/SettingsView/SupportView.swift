//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI

struct SupportView: View {
    var body: some View {
        Section("Support") {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("🍭 Lollypop")
                        .font(.caption)
                        .padding(.bottom, 4)
                    Text("Small but cute and it's sweet.")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
                Spacer()
                Button("2.99 PLN") {
                }
                .font(.footnote)
                .buttonStyle(.borderedProminent)
            }
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("☕️ Cofee")
                        .font(.caption)
                        .padding(.bottom, 4)
                    Text("More adrenaline before implemnenting something new.")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
                Spacer()
                Button("17.99 PLN") {
                }
                .font(.footnote)
                .buttonStyle(.borderedProminent)
            }
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("🍰 Cofee & cake")
                        .font(.caption)
                        .padding(.bottom, 4)
                    Text("More adrenaline and sugar, now we can create rocket into space.")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
                Spacer()
                Button("39.99 PLN") {
                }
                .font(.footnote)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

