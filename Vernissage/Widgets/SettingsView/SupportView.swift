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
                Text("🍩")
                    .font(.title)
                VStack(alignment: .leading) {
                    Text("Donut")
                        .font(.caption)
                    Text("Treat me to a doughnut.")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
                Spacer()
                Button("5.99 PLN") {
                }
                .font(.footnote)
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 4)
            
            HStack(alignment: .center) {
                Text("☕️")
                    .font(.title)
                VStack(alignment: .leading) {
                    Text("Cofee")
                        .font(.caption)
                    Text("Treat me to a coffe.")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
                Spacer()
                Button("17.99 PLN") {
                }
                .font(.footnote)
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 4)
            
            HStack(alignment: .center) {
                Text("🍰")
                    .font(.title)
                VStack(alignment: .leading) {
                    Text("Cofee & cake")
                        .font(.caption)
                    Text("Treat me to a coffe and cake.")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
                Spacer()
                Button("39.99 PLN") {
                }
                .font(.footnote)
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 4)
        }
    }
}

