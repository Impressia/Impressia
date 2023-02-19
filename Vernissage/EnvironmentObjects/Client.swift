//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import PixelfedKit

public class Client: ObservableObject {
    public static let shared = Client()
    private init() { }
    
    private var pixelfedClient: PixelfedClientAuthenticated?

    func setAccount(account: AccountModel) {
        guard let accessToken = account.accessToken else {
            return
        }
        
        self.pixelfedClient = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
    }
}

extension Client {
    public var trends: Trends? { return Trends(pixelfedClient: self.pixelfedClient) }
    public var publicTimeline: PublicTimeline? { return PublicTimeline(pixelfedClient: self.pixelfedClient) }
    public var tags: Tags? { return Tags(pixelfedClient: self.pixelfedClient) }
    public var notifications: Notifications? { return Notifications(pixelfedClient: self.pixelfedClient) }
    public var statuses: Statuses? { return Statuses(pixelfedClient: self.pixelfedClient) }
    public var media: Media? { return Media(pixelfedClient: self.pixelfedClient) }
    public var accounts: Accounts? { return Accounts(pixelfedClient: self.pixelfedClient) }
    public var search: Search? { return Search(pixelfedClient: self.pixelfedClient) }
    public var places: Places? { return Places(pixelfedClient: self.pixelfedClient) }
    public var instances: Instances { return Instances() }
}

public class BaseClient {
    public var pixelfedClient: PixelfedClientAuthenticated
    
    init?(pixelfedClient: PixelfedClientAuthenticated?) {
        guard let pixelfedClient else {
            return nil
        }

        self.pixelfedClient = pixelfedClient
    }
}
