//
//  StreamUser.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/11/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import GetStream

final class StreamUser: GetStream.User {
    private enum CodingKeys: String, CodingKey {
        case firstName, lastName, city, state, bio, imgURL
    }

    var firstName: String?
    var lastName: String?
    var city: String?
    var state: String?
    var bio: String?
    var imgURL: URL?

    var fullName: String? {
        return "\(firstName ?? "") \(lastName ?? "")"
    }

    required init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        let container = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        imgURL = try container.decodeIfPresent(URL.self, forKey: .imgURL)
        try super.init(from: decoder)
    }

    required init(id: String, name: String) {
        self.firstName = name
        super.init(id: id)
    }

    required init(id: String) {
        super.init(id: id)
    }

    override public func encode(to encoder: Encoder) throws {
        var dataContainer = encoder.container(keyedBy: DataCodingKeys.self)
        var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(bio, forKey: .bio)
        try container.encode(imgURL, forKey: .imgURL)
        try super.encode(to: encoder)
    }
}
