//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import NukeUI

struct InstanceRowView: View {
    @EnvironmentObject var routerPath: RouterPath

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
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .clipped()
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
                    Image(systemName: "person.2.fill")
                    Text(String(format: NSLocalizedString("signin.title.amountOfUsers", comment: "users"), stats.userCount))

                    Image(systemName: "photo.stack.fill")
                    Text(String(format: NSLocalizedString("signin.title.amountOStatuses", comment: "statuses"), stats.statusCount))

                    Spacer()
                }
                .padding(.top, 4)
                .foregroundColor(.lightGrayColor)
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
