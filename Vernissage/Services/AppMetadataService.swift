//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation
import PixelfedKit

public class AppMetadataService {
    public static let shared = AppMetadataService()
    private init() { }
    
    private let metadataUrl = URL(string: "https://raw.githubusercontent.com/VernissageApp/Home/main/instances.json")!
    private let metadataCacheKey = "metadataCacheKey"
    private var memoryCacheData = MemoryCache<String, AppMetadata>(entryLifetime: 600)
    
    public func metadata() async -> AppMetadata {
        do {
            if let metadata = self.memoryCacheData[metadataCacheKey] {
                return metadata
            }
            
            let (data, response) = try await URLSession.shared.data(from: metadataUrl)
            
            guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
                throw NetworkError.notSuccessResponse(response)
            }

            let metadata = try JSONDecoder().decode(AppMetadata.self, from: data)
            
            self.memoryCacheData[metadataCacheKey] = metadata
            return metadata
        } catch {
            ErrorService.shared.handle(error, message: "Error during downloading metadata.")
            return AppMetadata()
        }
    }
}
