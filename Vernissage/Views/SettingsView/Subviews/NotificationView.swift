//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import EnvironmentKit
import ServicesKit

struct NotificationView: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        @Bindable var applicationState = applicationState

        Section("settings.title.notifications") {

            Toggle(isOn: $applicationState.showApplicationBadge) {
                VStack(alignment: .leading) {
                    Text("settings.title.notificationsTitle", comment: "Show application badge")
                    Text("settings.title.notificationsDescription", comment: "Application badge with amount of new notifications will be visible near the app icon.")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
            }
            .onChange(of: self.applicationState.showApplicationBadge) { oldValue, newValue in
                Task { @MainActor in
                    do {
                        ApplicationSettingsHandler.shared.set(showApplicationBadge: newValue, modelContext: modelContext)
                        if newValue {
                            let center = UNUserNotificationCenter.current()
                            _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                        } else {
                            try await NotificationsService.shared.setBadgeCount(0, modelContext: modelContext)
                        }
                    } catch {
                        ErrorService.shared.handle(error, message: "settings.error.notificationEnableFailed", showToastr: false)
                    }
                }
            }
        }
    }
}
