//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation
import PixelfedKit

extension Client {
    public class Instances {        
        func instances(instanceUrls: [String]) async -> [Instance] {
            var instances: [Instance] = []
                        
            // Now we have to download information about each instance.
            await withTaskGroup(of: Instance?.self) { group in
                for url in instanceUrls {
                    group.addTask {
                        do {
                            if let baseUrl = URL(string: url) {
                                let client = PixelfedClient(baseURL: baseUrl)
                                return try await client.readInstanceInformation()
                            }
                            
                            return nil
                        } catch {
                            ErrorService.shared.handle(error, message: "Cannot download instance information: \(url.string)")
                            return nil
                        }
                    }
                }
                
                for await instance in group {
                    if let instance {
                        instances.append(instance)
                    }
                }
            }
            
            return instances
        }
        
        func instance(url: URL) async throws -> Instance {
            let client = PixelfedClient(baseURL: url)
            return try await client.readInstanceInformation()
        }
    }
}
