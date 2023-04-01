//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import UIKit
import SwiftUI

public struct ImageFileTranseferable: Transferable {
    let url: URL
    lazy var data: Data? = try? Data(contentsOf: url)

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
