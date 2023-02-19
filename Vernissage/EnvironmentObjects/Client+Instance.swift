//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

/// Mastodon 'Search'.
extension Client {
    public class Instances {
        private let urlJson = URL(string: "https://raw.githubusercontent.com/VernissageApp/Home/main/instances.json")!
        private let backupInstances: [String] = [
            "https://pixelfed.de",
            "https://pixelfed.social",
            "https://pxlmo.com",
            "https://metapixl.com",
            "https://pixey.org",
            "https://pixel.tchncs.de",
            "https://pixelfed.tokyo",
            "https://pixelfed.fr",
            "https://pixelfed.nz",
            "https://pixelfed.au",
            "https://pixelfed.eus",
            "https://pixelfed.bachgau.social",
            "https://pixelfed.es",
            "https://pixelfed.cz",
            "https://pixelfed.automat.click",
            "https://gram.social",
            "https://nixorigin.one",
            "https://miniature.photography",
            "https://fedifilm.art",
            "https://fedipix.de",
            "https://pixel.jabbxi.de",
            "https://nodegray.com",
            "https://socialpixels.xyz",
            "https://pixel.mamutut.space",
            "https://pixelfed.fioverse.zone",
            "https://pixel.artemai.art",
            "https://pix.anduin.net",
            "https://faf.photos",
            "https://pix.vleij.com",
            "https://pixels.gsi.li",
            "https://eorzea.photos"
        ]
        
        func instances() async -> [Instance] {
            var instances: [Instance] = []
            
            // First we have to download list of instances from github.
            let instanceUrls = await self.servers()
            
            // Now we have to download information about each instance.
            await withTaskGroup(of: Instance?.self) { group in
                for url in instanceUrls {
                    group.addTask {
                        do {
                            if let baseUrl = URL(string: url) {
                                let client = MastodonClient(baseURL: baseUrl)
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
            let client = MastodonClient(baseURL: url)
            return try await client.readInstanceInformation()
        }
        
        private func servers() async -> [String] {
            do {
                let (data, response) = try await URLSession.shared.data(from: urlJson)
                
                guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
                    throw NetworkError.notSuccessResponse(response)
                }

                let servers = try JSONDecoder().decode(Servers.self, from: data)
                return servers.instances
            } catch {
                ErrorService.shared.handle(error, message: "Error during downloading list of instances")
                return backupInstances
            }
        }
    }
}
