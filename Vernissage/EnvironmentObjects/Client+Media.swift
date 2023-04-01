//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

extension Client {
    public class Media: BaseClient {
        func upload(data: Data, fileName: String, mimeType: String) async throws -> UploadedAttachment? {
            return try await pixelfedClient.upload(data: data, fileName: fileName, mimeType: mimeType)
        }

        func update(id: String, description: String?, focus: CGPoint?) async throws -> UploadedAttachment? {
            return try await pixelfedClient.update(id: id, description: description, focus: focus)
        }
    }
}
