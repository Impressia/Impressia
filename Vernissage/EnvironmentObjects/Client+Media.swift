//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

/// Mastodon 'Statuses'.
extension Client {
    public class Media: BaseClient {
        func upload(data: Data, fileName: String, mimeType: String, description: String?, focus: CGPoint?) async throws -> UploadedAttachment? {
            return try await mastodonClient.upload(data: data, fileName: fileName, mimeType: mimeType, description: description, focus: focus)
        }
    }
}
