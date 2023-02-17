//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension MastodonClientAuthenticated {
    func upload(data: Data, fileName: String, mimeType: String, description: String?, focus: CGPoint?) async throws -> UploadedAttachment {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Media.upload(data, fileName, mimeType, description, focus),
            withBearerToken: token)

        return try await downloadJson(UploadedAttachment.self, request: request)
    }
}
