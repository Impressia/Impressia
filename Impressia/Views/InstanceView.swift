//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Foundation
import PixelfedKit
import ClientKit
import ServicesKit
import EnvironmentKit
import WidgetsKit

@MainActor
struct InstanceView: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(RouterPath.self) var routerPath
    @Environment(Client.self) var client

    @State private var state: ViewState = .loading
    @State private var instance: Instance?

    var body: some View {
        self.mainBody()
            .navigationTitle("instance.navigationBar.title")
    }

    @ViewBuilder
    private func mainBody() -> some View {
        switch state {
        case .loading:
            LoadingIndicator()
                .task {
                    await self.loadData()
                }
        case .loaded:
            if let instance = self.instance {
                self.details(instance: instance)
            } else {
                NoDataView(imageSystemName: "server.rack", text: "instance.error.noInstanceData")
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                await self.loadData()
            }
            .padding()
        }
    }

    @ViewBuilder
    private func details(instance: Instance) -> some View {
        List {
            Section("instance.title.instanceInfo") {
                self.dataRow(title: "instance.title.name", value: instance.title ?? String.empty())
                self.dataRow(title: "instance.title.address", value: "https://\(instance.uri)")

                VStack(alignment: .leading) {
                    if let description = instance.description {
                        MarkdownFormattedText(description.asMarkdown)
                            .font(.subheadline)
                            .environment(\.openURL, OpenURLAction { url in
                                routerPath.handle(url: url)
                            })
                            .padding(.vertical, 4)
                    }

                    if let shortDescription = instance.shortDescription {
                        Text(shortDescription)
                            .font(.footnote)
                            .foregroundColor(.customGrayColor)
                    }
                }

                self.dataRow(title: "instance.title.version", value: instance.version)
                self.dataRow(title: "instance.title.users", value: "\(instance.stats?.userCount ?? 0)")
                self.dataRow(title: "instance.title.posts", value: "\(instance.stats?.statusCount ?? 0)")
                self.dataRow(title: "instance.title.domains", value: "\(instance.stats?.domainCount ?? 0)")

                Toggle("instance.title.registrations", isOn: Binding.constant(instance.registrations))
                    .disabled(true)
                Toggle("instance.title.approvalRequired", isOn: Binding.constant(instance.approvalRequired))
                    .disabled(true)
            }

            Section("instance.title.contact") {
                self.dataRow(title: "instance.title.email", value: instance.email ?? String.empty())

                if let contactAccount = instance.contactAccount {
                    NavigationLink(value: RouteurDestinations.userProfile(
                        accountId: contactAccount.id,
                        accountDisplayName: contactAccount.displayNameWithoutEmojis,
                        accountUserName: contactAccount.acct)
                    ) {
                        HStack {
                            Text("instance.title.pixelfedAccount", comment: "Pixelfed account")
                            Spacer()
                            Text("@\(contactAccount.displayNameWithoutEmojis)")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }

            if let rules = self.instance?.rules {
                Section("instance.title.rules") {
                    ForEach(rules, id: \.id) { rule in
                        Text(rule.text)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dataRow(title: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(title, comment: "Title")
            Spacer()
            Text(value)
                .foregroundColor(.customGrayColor)
                .font(.subheadline)
        }
    }

    private func loadData() async {
        do {
            if let serverUrl = self.applicationState.account?.serverUrl {
                self.instance = try await self.client.instances.instance(url: serverUrl)
            }

            withAnimation {
                self.state = .loaded
            }
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "instance.error.loadingDataFailed", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "instance.error.loadingDataFailed", showToastr: false)
            }
        }
    }
}
