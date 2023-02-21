//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import PixelfedKit
import AuthenticationServices

struct SignInView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client

    @State private var serverAddress = String.empty()
    @State private var instructionsUrlString:String?
    @State private var instances: [Instance] = []
        
    var onSignedIn: ((_ accountData: AccountData) -> Void)?
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 4) {
                        TextField("Server address", text: $serverAddress)
                            .onSubmit {
                                let baseAddress = self.getServerAddress(uri: self.serverAddress)
                                self.signIn(baseAddress: baseAddress)
                            }
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .disableAutocorrection(true)
                        
                        Button("Sign in") {
                            HapticService.shared.fireHaptic(of: .buttonPress)

                            let baseAddress = self.getServerAddress(uri: self.serverAddress)
                            self.signIn(baseAddress: baseAddress)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("Enter server address")
            } footer: {
                if let instructionsUrlString = self.instructionsUrlString,
                   let instructionsUrl = URL(string: instructionsUrlString) {
                    HStack {
                        Spacer()
                        Link("How to join Pixelfed", destination: instructionsUrl)
                            .font(.caption)
                    }
                }
            }
            
            Section("Or choose Pixelfed server") {
                if self.instances.isEmpty {
                    HStack {
                        Spacer()
                        LoadingIndicator()
                        Spacer()
                    }
                }
                
                ForEach(self.instances, id: \.uri) { instance in                    
                    InstanceRowView(instance: instance) { uri in
                        let baseAddress = self.getServerAddress(uri: uri)
                        self.signIn(baseAddress: baseAddress)
                    }
                }
            }
        }
        .onFirstAppear {
            let metadata = await AppMetadataService.shared.metadata()
            self.instances = await self.client.instances.instances(instanceUrls: metadata.instances)
            self.instructionsUrlString = metadata.instructionsUrl
        }
        .navigationTitle("Sign in to Pixelfed")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func signIn(baseAddress: String) {
        Task {
            do {
                let authorizationSession = AuthorizationSession()
                try await AuthorizationService.shared.sign(in: baseAddress, session: authorizationSession) { accountData in
                    onSignedIn?(accountData)
                    
                    DispatchQueue.main.sync {
                        dismiss()
                    }
                }
            } catch let error as AuthorisationError {
                ErrorService.shared.handle(error, message: error.localizedDescription, showToastr: true)
            }
            catch {
                ErrorService.shared.handle(error, message: "Error during communication with server", showToastr: true)
            }
        }
    }
    
    private func getServerAddress(uri: String) -> String {
        if !uri.starts(with: "https://") {
            return "https://\(uri)"
        }
        
        return uri
    }
}
