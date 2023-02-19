//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension PixelfedClientAuthenticated {
    func upload(data: Data, fileName: String, mimeType: String) async throws -> UploadedAttachment {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Media.upload(data, fileName, mimeType),
            withBearerToken: token)

        return try await downloadJson(UploadedAttachment.self, request: request)
    }
    
    func update(id: EntityId, description: String?, focus: CGPoint?) async throws -> UploadedAttachment {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Media.update(id, description, focus),
            withBearerToken: token)

        let (data, response) = try await urlSession.data(for: request)
        
        // TODO: Pixelfed.social returns some list instead of single media!
        // return try await downloadJson(UploadedAttachment.self, request: request)
        
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }

        do {
            return try JSONDecoder().decode(UploadedAttachment.self, from: data)
        } catch {
            do {
                let list = try JSONDecoder().decode([UploadedAttachment].self, from: data)
                print("[Error] Instead of single item server retured list of others media attachments!")
                
                if let entity = list.first(where: { item in item.id == id }) {
                    return entity
                }
                
                throw NetworkError.unknownError
            } catch {
                let json = String(data: data, encoding: .utf8)!
                print(json)
                
                throw error
            }
        }
    }
}
