//
//  UserRecommendations.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/11/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

import SwiftUI

struct UserRecommendations {
    var recipesLoadedSem: DispatchSemaphore?
    let db = Firestore.firestore()

    func FilterDiet(q: Query, filter: Filter) -> Query {
        var query = q
        for allergy in filter.selectedAllergies {
            switch allergy {
            case .alcohol:
                query = query.whereField("health.Alcohol-Free", isEqualTo: true)
            case .dairy:
                query = query.whereField("health.Dairy-Free", isEqualTo: true)
            case .eggs:
                query = query.whereField("health.Egg-Free", isEqualTo: true)
            case .fish:
                query = query.whereField("health.Fish-Free", isEqualTo: true)
            case .glutenFree:
                query = query.whereField("health.Gluten-Free", isEqualTo: true)
            case .peanuts:
                query = query.whereField("health.Peanut-Free", isEqualTo: true)
            }
        }

        switch filter.selectedDiet {
        case .vegan:
            query = query.whereField("health.Vegan", isEqualTo: true)
        case .vegetarian:
            query = query.whereField("health.Vegetarian", isEqualTo: true)
        case .keto:
            query = query.whereField("health.Keto", isEqualTo: true)
        case .paleo:
            query = query.whereField("health.Paleo", isEqualTo: true)
        case .kosher:
            query = query.whereField("health.Kosher", isEqualTo: true)
        case .pescatarian:
            query = query.whereField("health.Pescatarian", isEqualTo: true)
        case .none:
            break
        }

        return query
    }

    func GetReccomendations(filter: Filter, getFeatured: Bool, completion: @escaping (Bool, [Recommendation]?) -> Void) {

        var query: Query

        if getFeatured {
            query = db.collection("featuredRecipes")
        } else {
            query = db.collection("recipeInfo").limit(to: 5).order(by: "count", descending: true)
        }

        query = FilterDiet(q: query, filter: filter)

        query.getDocuments { (snap, err) in
            if let err = err {
                print("Error getting recipe counts: \(err.localizedDescription)")
                completion(false, nil)
                return
            }

            let recs = (snap?.documents.compactMap {
                return try? $0.data(as: Recommendation.self)
            })!

            completion(true, recs)
            return

            /*
            let dispatchQueue = DispatchQueue(label: "waitingForLoadQueue", qos: .background)
            dispatchQueue.async{
                if let sem = self.recipesLoadedSem {
                    sem.wait()
                }
                
                DispatchQueue.main.async {
                    let defaults = UserDefaults.standard
                    if let savedRecipes = defaults.object(forKey: "SavedRecipes") as? [String] {
                        let recsFiltered = recs.filter{ savedRecipes.contains($0.uri) == false }
                        completion(true, recsFiltered)
                    } else {
                        completion(true, recs)
                    }
                }
            }
 */
        }
    }
}

class Recommendation: ObservableObject, Codable, Equatable, Identifiable {
    var id = UUID()
    var uri: String
    var count: Int
    var name: String
    var calories: Float
    var health: [String: Bool]
    var featuredSection: String?
    @Published var loadedImage: Image?

    enum CodingKeys: CodingKey {
        case uri, count, name, health, calories, featuredSection
    }

    init(uri: String, count: Int, name: String, calories: Float, health: [String: Bool]) {
        self.uri = uri
        self.count = count
        self.name = name
        self.calories = calories
        self.health = health
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        uri = try container.decode(String.self, forKey: .uri)
        count = try container.decode(Int.self, forKey: .count)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Float.self, forKey: .calories)
        health = try container.decode([String: Bool].self, forKey: .health)
        featuredSection = try container.decodeIfPresent(String.self, forKey: .featuredSection)
        GetImageFromStorage()
    }

    func GetImageFromStorage() {
        let ref = Storage.storage().reference()
        let recipeImageRef = ref.child("images/\(uri).jpg")

        recipeImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error getting image from cloud storage \(error.localizedDescription)")
            } else {
                if let UIImg = UIImage(data: data!) {
                    self.loadedImage = Image(uiImage: UIImg)
                }
            }
        }
    }

    static func ==(lhs: Recommendation, rhs: Recommendation) -> Bool {
        return lhs.uri == rhs.uri
    }
}
