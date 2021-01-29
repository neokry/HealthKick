//
//  UserRatings.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/15/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserRecipeRating: Codable, ObservableObject {
    var userID: String
    var URI: String
    @Published var rating = 2
    let db = Firestore.firestore()

    enum CodingKeys: CodingKey {
        case userID, URI, rating
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(userID, forKey: .userID)
        try container.encode(URI, forKey: .URI)
        try container.encode(rating, forKey: .rating)
    }

    init(userID: String, URI: String) {
        self.userID = userID
        self.URI = URI

        getRatingData(userID: userID, URI: URI) { (success, rating) in
            if success {
                self.rating = rating
            }

        }
    }

    func getRatingData(userID: String, URI: String, completion: @escaping (Bool, Int) -> Void) {
        let ratings = db.collection("userRecipeRatings").document(userID).collection("ratingData").document(URI)
        ratings.getDocument { (doc, err) in
            if let err = err {
                print("Error getting rating for recipe \(err)")
                completion(false, 2)
                return
            }

            if let ratingInt = doc?.data()?["rating"] as? Int {
                completion(true, ratingInt)
                return
            }

            if self.rating != 2 {
                Analytics.logEvent("rated_recipe", parameters: [
                    "rating": self.rating
                 ])
            }
        }
    }

    func saveRating() {
        do {
            let ratings = db.collection("userRecipeRatings").document(userID).collection("ratingData").document(URI)
            try ratings.setData(from: self) { err in
                if let err = err {
                    print("Error saving rating \(err.localizedDescription)")
                }
            }
        } catch {
            print("Error saving rating \(error.localizedDescription)")
            Crashlytics.crashlytics().log("Error saving rating \(error.localizedDescription)")
        }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        userID = try container.decode(String.self, forKey: .userID)
        URI = try container.decode(String.self, forKey: .URI)
        rating = try container.decode(Int.self, forKey: .rating)
    }
}
