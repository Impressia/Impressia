//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import AuthenticationServices
import ServicesKit
import EnvironmentKit
import WidgetsKit

@MainActor
struct SignInView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @Environment(ApplicationState.self) var applicationState
    @Environment(RouterPath.self) var routerPath
    @Environment(Client.self) var client

    @State private var serverAddress = String.empty()
    @State private var instructionsUrlString: String?
    @State private var instances: [Instance] = []

    var onSignedIn: ((_ accountModel: AccountModel) -> Void)?

    var body: some View {
        List {
            Section {
                VStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 4) {
                        TextField("signin.title.serverAddress", text: $serverAddress)
                            .onSubmit {
                                let baseAddress = self.getServerAddress(uri: self.serverAddress)
                                self.signIn(baseAddress: baseAddress)
                            }
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .disableAutocorrection(true)
                            .clearButton(text: $serverAddress)
                        
                        Button(NSLocalizedString("signin.title.signIn", comment: "Sign in")) {
                            HapticService.shared.fireHaptic(of: .buttonPress)
                            
                            let baseAddress = self.getServerAddress(uri: self.serverAddress)
                            self.signIn(baseAddress: baseAddress)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.vertical, 4)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
            } header: {
                Text("signin.title.enterServerAddress", comment: "Enter server address")
            } footer: {
                if let instructionsUrlString = self.instructionsUrlString,
                   let instructionsUrl = URL(string: instructionsUrlString) {
                    HStack {
                        Spacer()
                        Link(NSLocalizedString("signin.title.howToJoinLink", comment: "How to join Pixelfed"), destination: instructionsUrl)
                            .font(.caption)
                    }
                }
            }
            
            Section("signin.title.chooseServer") {
                if self.instances.isEmpty {
                    HStack {
                        Spacer()
                        LoadingIndicator()
                        Spacer()
                    }
                }
                
                ForEach(self.instances.filter { self.serverAddress.isEmpty || $0.uri.contains(self.serverAddress) }, id: \.uri) { instance in
                    InstanceRowView(instance: instance) { uri in
                        let baseAddress = self.getServerAddress(uri: uri)
                        self.signIn(baseAddress: baseAddress)
                    }
                }
            }
        }
        .onFirstAppear {
            let metadata = await AppMetadataService.shared.metadata()
            self.instances = metadata.instances
            self.instructionsUrlString = metadata.instructionsUrl
        }
        .navigationTitle("signin.navigationBar.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signIn(baseAddress: String) {
        Task {
            do {
                let authorizationSession = AuthorizationSession()
                try await AuthorizationService.shared.sign(in: baseAddress, session: authorizationSession) { accountModel in
                    onSignedIn?(accountModel)

                    DispatchQueue.main.sync {
                        dismiss()
                    }
                }
            } catch let error as AuthorisationError {
                ErrorService.shared.handle(error, localizedMessage: error.localizedDescription, showToastr: true)
            } catch {
                ErrorService.shared.handle(error, message: "signin.error.communicationFailed", showToastr: true)
            }
        }
    }

    private func getServerAddress(uri: String) -> String {
        var address = uri.trimmingCharacters(in: .whitespacesAndNewlines)
        address = address.trimmingCharacters(in: CharacterSet.init(charactersIn: "/\\"))

        if !address.starts(with: "https://") {
            return "https://\(address)"
        }

        return address
    }
}
