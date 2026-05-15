//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import NukeUI
import ServicesKit
import WidgetsKit

struct InstanceRowView: View {
    @Environment(RouterPath.self) var routerPath

    private let instance: Instance
    private let action: (String) -> Void

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private static let spellOutFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter
    }()

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
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .clipped()
                            .accessibilityHidden(true)
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
                    }.accessibilityElement(children: .combine)

                    Spacer()

                    Button(NSLocalizedString("signin.title.signIn", comment: "Sign in")) {
                        HapticService.shared.fireHaptic(of: .buttonPress)
                        self.action(instance.uri)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 4)
                }
            }

            if let description = instance.description {
                MarkdownFormattedText(description.asMarkdown)
                    .font(.subheadline)
                    .environment(\.openURL, OpenURLAction { url in
                        routerPath.handle(url: url)
                    })
            }

            if let stats = instance.stats {
                HStack {
                    // Display formatted figures according to locale, but keep vocalizable version for Voice Over
                    let localizedStringForUsers = NSLocalizedString("signin.title.amountOfUsers", comment: "users")
                    let localizedStringForStatuses = NSLocalizedString("signin.title.amountOStatuses", comment: "statuses")
                    
                    Image(systemName: "person.2.fill").accessibilityHidden(true)
                    Text(String(format: localizedStringForUsers,
                                Self.numberFormatter.string(from: NSNumber(value: stats.userCount)) ?? "\(stats.userCount)"))
                        .accessibilityLabel(String(format: localizedStringForUsers,
                            Self.spellOutFormatter.string(from: NSNumber(value: stats.userCount)) ?? "\(stats.userCount)"))

                    Image(systemName: "photo.stack.fill").accessibilityHidden(true)
                    Text(String(format: localizedStringForStatuses,
                                Self.numberFormatter.string(from: NSNumber(value: stats.statusCount)) ?? "\(stats.statusCount)"))
                        .accessibilityLabel(String(format: localizedStringForStatuses,
                            Self.spellOutFormatter.string(from: NSNumber(value: stats.statusCount)) ?? "\(stats.statusCount)"))
                                            
                    Spacer()
                }
                .padding(.top, 4)
                .foregroundColor(.customGrayColor)
                .font(.caption)
            }
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
