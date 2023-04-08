//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Foundation

public struct ImageFileTranseferable: Transferable {
    public let url: URL

    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .image) { image in
            SentTransferredFile(image.url)
        } importing: { received in
            Self(url: localURLFor(received: received))
        }
    }
}

private func localURLFor(received: ReceivedTransferredFile) -> URL {
    let copy = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).\(received.file.pathExtension)")
    try? FileManager.default.copyItem(at: received.file, to: copy)
    return copy
}
