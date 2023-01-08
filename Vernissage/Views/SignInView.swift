//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct SignInView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var applicationState: ApplicationState

    @State private var serverAddress: String = ""
    
    var onSignInStateChenge: ((_ applicationViewMode: ApplicationViewMode) -> Void)?
    
    var body: some View {
        VStack {
            // TODO: Rebild signin.
            HStack {
                TextField(
                    "Server address",
                    text: $serverAddress
                )
                .onSubmit {
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                
                Button("Go") {
                    Task {
                        try await AuthorizationService.shared.signIn(serverAddress: serverAddress, { accountData in
                            DispatchQueue.main.async {
                                self.applicationState.accountData = accountData
                                onSignInStateChenge?(.mainView)
                            }
                        })
                    }
                }
            }
        }
        .padding()
        .navigationBarTitle("Sign in to Pixelfed")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
