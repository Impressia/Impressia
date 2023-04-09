//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import StoreKit
import ServicesKit

struct SupportView: View {
    @EnvironmentObject var tipsStore: TipsStore

    var body: some View {
        Section("settings.title.support") {
            ForEach(tipsStore.items) { product in
                HStack(alignment: .center) {
                    Text(self.getIcon(for: product))
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text(product.displayName)
                        Text(product.description)
                            .font(.footnote)
                            .foregroundColor(.lightGrayColor)
                    }
                    Spacer()
                    Button(product.displayPrice) {
                        HapticService.shared.fireHaptic(of: .buttonPress)

                        Task {
                            await tipsStore.purchase(product)
                        }
                    }
                    .font(.footnote)
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func getIcon(for product: Product) -> String {
        if product.id == ProductIdentifiers.donut.rawValue {
            return "🍩"
        } else if product.id == ProductIdentifiers.cofee.rawValue {
            return "☕️"
        } else {
            return "🍰"
        }
    }
}
