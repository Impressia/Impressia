//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit
import AuthenticationServices

struct SignInView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var applicationState: ApplicationState

    @State private var serverAddress: String = String.empty()
    @State private var instances: [Instance] = []
        
    var onSignInStateChenge: ((_ applicationViewMode: ApplicationViewMode) -> Void)?
    
    var body: some View {
        List {
            
            Section("Custom server address") {
                // Custom server address.
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
                            let baseAddress = self.getServerAddress(uri: self.serverAddress)
                            self.signIn(baseAddress: baseAddress)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // List of predefined servers.
            Section("Pixelfed servers") {
                if self.instances.isEmpty {
                    HStack {
                        Spacer()
                        LoadingIndicator()
                        Spacer()
                    }
                }
                
                ForEach(self.instances, id: \.uri) { instance in                    
                    InstanceRow(instance: instance) { uri in
                        let baseAddress = self.getServerAddress(uri: uri)
                        self.signIn(baseAddress: baseAddress)
                    }
                }
            }
            
        }
        .onFirstAppear {
            self.instances = await InstanceService.shared.instances(urls: InstanceService.shared.pixelfedInstances)
        }
        .navigationBarTitle("Sign in to Pixelfed")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func signIn(baseAddress: String) {
        Task {
            do {
                
                let authorizationSession = AuthorizationSession()
                try await AuthorizationService.shared.sign(in: baseAddress,
                                                           session: authorizationSession) { accountData in
                    DispatchQueue.main.async {
                        self.applicationState.account = AccountModel(accountData: accountData)
                        onSignInStateChenge?(.mainView)
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
