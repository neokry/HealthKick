//
//  FeedItem.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/11/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import GetStream

final class FeedItem: EnrichedActivity<StreamUser, String, DefaultReaction>, Identifiable {
    private enum CodingKeys: String, CodingKey {
        case imgURL, caption, recipeID, target
    }

    var imgURL: URL?
    var caption: String?
    var recipeID: String?
    var target: String?

    var friendlyTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        let d = formatter.string(from: time ?? Date())
        formatter.dateFormat = "h:m a"
        let t = formatter.string(from: time ?? Date())
        return "\(d) at \(t)"
    }

    init(actor: StreamUser, verb: Verb, object: ObjectType, imgURL: URL?, caption: String, recipeID: String?) {
        self.imgURL = imgURL
        self.caption = caption
        self.recipeID = recipeID
        self.target = UUID().uuidString
        super.init(actor: actor, verb: verb, object: object, foreignId: object)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imgURL = try container.decodeIfPresent(URL.self, forKey: .imgURL)
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        recipeID = try container.decodeIfPresent(String.self, forKey: .recipeID)
        target = try container.decodeIfPresent(String.self, forKey: .target)
        try super.init(from: decoder)
    }

    required init(actor: ActorType, verb: Verb, object: ObjectType, foreignId: String? = nil, time: Date? = nil, feedIds: FeedIds? = nil, originFeedId: FeedId? = nil) {
        fatalError("init(actor:verb:object:foreignId:time:feedIds:originFeedId:) has not been implemented")
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imgURL, forKey: .imgURL)
        try container.encode(caption, forKey: .caption)
        try container.encode(recipeID, forKey: .recipeID)
        try container.encode(target, forKey: .target)
        try super.encode(to: encoder)
    }
}
