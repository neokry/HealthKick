//
//  AdminFeaturedRecipes.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/23/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum FeaturedRecipeSections: String, CaseIterable {
    case salad, pasta, latin, seafood, eastern
}

class AdminFeaturedRecipes: ObservableObject {
    @Published var recipesForSection: [Recommendation]?
    let db = Firestore.firestore()

    func loadForSection(sectionID: String) {
        let recipesRef = db.collection("featuredRecipes").whereField("featuredSection", isEqualTo: sectionID)
        recipesRef.getDocuments { (snap, err) in
            if let err = err {
                print("Error getting featured recipes \(err)")
                return
            }

            let tmp = (snap?.documents.compactMap {
                try? $0.data(as: Recommendation.self)
            })!

            self.recipesForSection = tmp
        }
    }

    func deleteForSection(sectionID: String, completion: @escaping (Bool) -> Void) {
        let recipesRef = db.collection("featuredRecipes").whereField("featuredSection", isEqualTo: sectionID)
        recipesRef.getDocuments { (snap, err) in
            if let err = err {
                print("Error getting featured recipes \(err)")
                return
            }

            if snap!.documents.count == 0 {
                completion(true)
                return
            }

            for doc in snap!.documents {
                self.db.collection("featuredRecipes").document(doc.documentID).delete { err in
                    if let err = err {
                        print("Error deleting recipes \(err)")
                    }
                    completion(true)
                }
            }
        }
    }

    func saveForSection(sectionID: String, recipes: [UserRecipe]) {
        for recipe in recipes {
            db.collection("recipeInfo").document(recipe.encodedURI).getDocument { (snap, err) in
                if let err = err {
                    print("Error getting recipe info \(err)")
                } else {
                    let recipeRef = self.db.collection("featuredRecipes").document(recipe.encodedURI)
                    if var data = snap?.data() {
                        data["featuredSection"] = sectionID
                        recipeRef.setData(data) { err in
                            if let err = err {
                                print("Error adding recipe to featured section \(err)")
                                return
                            }
                            if recipe == recipes.last {
                                self.loadForSection(sectionID: sectionID)
                            }
                        }
                    }
                }
            }
        }
    }
}
