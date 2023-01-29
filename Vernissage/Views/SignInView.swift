//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var applicationState: ApplicationState

    @State private var serverAddress: String = String.empty()
    @State private var pixelfedInstances: [String] = [
        "pixelfed.de", "pixelfed.social", "pxlmo.com", "metapixl.com", "pixey.org",
        "pixel.tchncs.de", "pixelfed.tokyo", "pixelfed.fr", "pixelfed.nz", "pixelfed.au",
        "pixelfed.eus", "pixelfed.bachgau.social"
    ]
    
    var onSignInStateChenge: ((_ applicationViewMode: ApplicationViewMode) -> Void)?
    
    var body: some View {
        List {
            
            Section("Custom server address") {
                // Custom server address.
                VStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 4) {
                        TextField("Server address", text: $serverAddress)
                            .onSubmit {
                                self.signIn()
                            }
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .disableAutocorrection(true)
                        
                        Button("Sign in") {
                            self.signIn()
                        }.buttonStyle(.borderedProminent)
                    }
                }
            }
            
            // List of predefined servers.
            Section("Pixelfed servers") {
                ForEach(pixelfedInstances, id: \.self) { address in
                    NavigationLink(value: RouteurDestinations.signIn) {
                        VStack {
                            Text(address)
                        }
                    }
                }
            }
            
        }
        .task {
            
        }
        .navigationBarTitle("Sign in to Pixelfed")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func signIn() {
        Task {
            do {
                
                let authorizationSession = AuthorizationSession()
                try await AuthorizationService.shared.sign(in: self.getServerAddress(),
                                                           session: authorizationSession) { accountData in
                    DispatchQueue.main.async {
                        self.applicationState.accountData = accountData
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
    
    private func getServerAddress() -> String {
        if !serverAddress.starts(with: "https://") {
            return "https://\(serverAddress)"
        }
        
        return serverAddress
    }
}
