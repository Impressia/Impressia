//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import ServicesKit
import WidgetsKit

@MainActor
struct ReportView: View {
    @Environment(Client.self) var client
    @Environment(\.dismiss) private var dismiss

    @State private var publishDisabled = false
    @State private var reportType = Report.ReportType.sensitive

    private let objectType: Report.ObjectType
    private let objectId: String

    private let reportTypes: [(reportType: Report.ReportType, name: LocalizedStringKey)] = [
        (Report.ReportType.spam, "report.title.spam"),
        (Report.ReportType.sensitive, "report.title.sensitive"),
        (Report.ReportType.abusive, "report.title.abusive"),
        (Report.ReportType.underage, "report.title.underage"),
        (Report.ReportType.violence, "report.title.violence"),
        (Report.ReportType.copyright, "report.title.copyright"),
        (Report.ReportType.impersonation, "report.title.impersonation"),
        (Report.ReportType.scam, "report.title.scam"),
        (Report.ReportType.terrorism, "report.title.terrorism")
    ]

    init(objectType: Report.ObjectType, objectId: String) {
        self.objectType = objectType
        self.objectId = objectId
    }

    var body: some View {
        NavigationView {
            Form {
                Section("report.title.reportType") {

                    ForEach(self.reportTypes, id: \.reportType) { item in
                        Button {
                            self.reportType = item.reportType
                        } label: {
                            HStack(alignment: .center) {
                                Text(item.name, comment: "Report type")
                                    .font(.subheadline)
                                    .foregroundColor(.mainTextColor)

                                Spacer()

                                if self.reportType == item.reportType {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            .frame(alignment: .topLeading)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    ActionButton {
                        await onSendReport()
                    } label: {
                        Text("report.title.send", comment: "Send")
                    }
                    .disabled(self.publishDisabled)
                    .buttonStyle(.borderedProminent)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("report.title.close", comment: "Close"), role: .cancel) {
                        self.dismiss()
                    }
                }
            }
            .navigationTitle("report.navigationBar.title")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func onSendReport() async {
        do {
            if try await self.client.reports?.report(objectType: self.objectType,
                                                     objectId: self.objectId,
                                                     reportType: self.reportType) != nil {
                switch self.objectType {
                case .post:
                    ToastrService.shared.showSuccess("report.title.postReported", imageSystemName: "exclamationmark.triangle")
                case .user:
                    ToastrService.shared.showSuccess("report.title.userReported", imageSystemName: "exclamationmark.triangle")
                }

                self.dismiss()
            }
        } catch {
            ErrorService.shared.handle(error, message: "report.error.notReported", showToastr: true)
        }
    }
}
