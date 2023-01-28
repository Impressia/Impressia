//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct SignInView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var applicationState: ApplicationState

    @State private var serverAddress: String = String.empty()
    
    var onSignInStateChenge: ((_ applicationViewMode: ApplicationViewMode) -> Void)?
    
    var body: some View {
        VStack {
            // TODO: Rebuild signin page.
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
                        do {
                            try await AuthorizationService.shared.sign(in: serverAddress, { accountData in
                                DispatchQueue.main.async {
                                    self.applicationState.accountData = accountData
                                    onSignInStateChenge?(.mainView)
                                    dismiss()
                                }
                            })
                        } catch {
                            ErrorService.shared.handle(error, message: "Error during communication with server", showToastr: true)
                        }
                    }
                }
            }
        }
        .padding()
        .navigationBarTitle("Sign in to Pixelfed")
        .navigationBarTitleDisplayMode(.inline)
    }
}
