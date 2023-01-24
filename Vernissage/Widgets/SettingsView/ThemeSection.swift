//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct ThemeSection: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Section("Theme") {
            Button {
                self.applicationState.theme = .system
                ApplicationSettingsHandler.shared.setDefaultTheme(theme: .system)
            } label: {
                HStack {
                    Text("System")
                        .foregroundColor(.label)
                    Spacer()
                    if self.applicationState.theme == .system {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Button {
                self.applicationState.theme = .light
                ApplicationSettingsHandler.shared.setDefaultTheme(theme: .light)
            } label: {
                HStack {
                    Text("Light")
                        .foregroundColor(.label)
                    Spacer()
                    if self.applicationState.theme == .light {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Button {
                self.applicationState.theme = .dark
                ApplicationSettingsHandler.shared.setDefaultTheme(theme: .dark)
            } label: {
                HStack {
                    Text("Dark")
                        .foregroundColor(.label)
                    Spacer()
                    if self.applicationState.theme == .dark {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}
