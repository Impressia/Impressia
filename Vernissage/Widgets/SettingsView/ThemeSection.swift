//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct ThemeSection: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.colorScheme) var colorScheme

    var onThemeChange: ((Theme) -> Void)?
    
    var body: some View {
        Section("Theme") {
            Button {
                onThemeChange?(.system)
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
                onThemeChange?(.light)
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
                onThemeChange?(.dark)
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
