//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation
import PixelfedKit

/// Information about trending hashtag.
public struct HashtagModel {

    /// Id number of tag.
    public let id: Int

    /// The value of the hashtag.
    public let name: String
    
    /// The value of the hashtag after the # sign.
    public let hashtag: String
    
    /// A link to the hashtag on the instance.
    public let url: String?
    
    /// Total uses of hashtag.
    public let total: Int?
    
    init(tagTrend: TagTrend) {
        self.id = tagTrend.id
        self.name = tagTrend.name
        self.hashtag = tagTrend.hashtag
        self.url = tagTrend.url
        self.total = tagTrend.total
    }
    
    init(tag: Tag) {
        self.id = Int.random(in: 1...9_999_999)
        self.name = "#\(tag.name)"
        self.hashtag = tag.name
        self.url = tag.url
        self.total = nil
    }
}
