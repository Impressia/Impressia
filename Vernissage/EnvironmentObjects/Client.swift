//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

public class Client: ObservableObject {
    public static let shared = Client()
    private init() { }
    
    private var mastodonClient: MastodonClientAuthenticated?

    func setAccount(account: AccountModel) {
        guard let accessToken = account.accessToken else {
            return
        }
        
        self.mastodonClient = MastodonClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
    }
}

extension Client {
    public var trends: Trends? { return Trends(mastodonClient: self.mastodonClient) }
    public var publicTimeline: PublicTimeline? { return PublicTimeline(mastodonClient: self.mastodonClient) }
    public var tags: Tags? { return Tags(mastodonClient: self.mastodonClient) }
    public var notifications: Notifications? { return Notifications(mastodonClient: self.mastodonClient) }
    public var statuses: Statuses? { return Statuses(mastodonClient: self.mastodonClient) }
    public var media: Media? { return Media(mastodonClient: self.mastodonClient) }
    public var accounts: Accounts? { return Accounts(mastodonClient: self.mastodonClient) }
    public var search: Search? { return Search(mastodonClient: self.mastodonClient) }
    public var instances: Instances { return Instances() }
}

public class BaseClient {
    public var mastodonClient: MastodonClientAuthenticated
    
    init?(mastodonClient: MastodonClientAuthenticated?) {
        guard let mastodonClient else {
            return nil
        }

        self.mastodonClient = mastodonClient
    }
}
