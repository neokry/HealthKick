//
//  RecipeData.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/30/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseCrashlytics

class UserRecipes: ObservableObject {

    @Published private(set) var recipes: [UserRecipe]
    var userID: String
    let db = Firestore.firestore()

    func addRecipe(recipe: Recipe, cache: ImageCache) {
        do {
            let userRecipes = db.collection("userRecipes").document(userID)
            let newRecipe = userRecipes.collection("recipes").document(recipe.encodedURI)
            let cacheRecipe = UserRecipe(recipeName: recipe.label, recipeURI: recipe.uri, totalNutrients: recipe.friendlyTotalNutrients, totalDaily: recipe.friendlyDailyNutrients, calories: recipe.calories, yeild: recipe.yield)

            try newRecipe.setData(from: cacheRecipe) { err in
                if let err = err {
                    print("Error adding recipe to database \(err.localizedDescription)")
                } else {

                    self.SaveImageInStorage(uri: cacheRecipe.encodedURI, url: recipe.imageURL, cache: cache) { success in
                        if success {
                            cacheRecipe.GetImageFromStorage()
                            self.recipes.append(cacheRecipe)
                        }
                    }

                    Analytics.logEvent("add_recipe", parameters: [
                        "name": recipe.label
                    ])
                }
            }

        } catch {
            print("Error adding recipe to database \(error.localizedDescription)")
            Crashlytics.crashlytics().log("Error adding recipe to database \(error.localizedDescription)")
        }
    }

    func removeRecipe(recipe: Recipe, cache: ImageCache) {
        let userRecipes = db.collection("userRecipes").document(userID)
        let selectedRecipe = userRecipes.collection("recipes").document(recipe.encodedURI)

        selectedRecipe.delete { err in
            if let err = err {
                print("Error deleting recipe from database \(err.localizedDescription)")
                return
            }

            if let selectedRecipe = self.recipes.first(where: {$0.recipeURI == recipe.uri }) {
                self.recipes.remove(object: selectedRecipe)
            }
        }
    }

    func SaveImageInStorage(uri: String, url: URL?, cache: ImageCache, completion: @escaping (Bool) -> Void) {
        let ref = Storage.storage().reference()
        let recipeImageRef = ref.child("images/\(uri).jpg")

        recipeImageRef.getMetadata { (_, err) in
            if err == nil {
                completion(true)
                return //Image is already in storage dont need it twice
            }

            if let imgURL = url {
                if let img = cache[imgURL] {
                    if let data = img.jpegData(compressionQuality: 0.8) {
                        recipeImageRef.putData(data, metadata: nil) { (_, error) in
                            if let error = error {
                                print("Error: \(error.localizedDescription) saving recipe image in cloud storage")
                                completion(false)
                            } else {
                                completion(true)
                            }

                            return
                        }
                    }
                }
            }
        }

    }

    func loadRecipes(completion: @escaping (Bool, [UserRecipe]?) -> Void) {
        let userRecipesCollection = db.collection("userRecipes").document(userID)
        let recipesCollection = userRecipesCollection.collection("recipes")

        recipesCollection.getDocuments { (querySnapshot, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                completion(false, nil)
                return
            }

            self.recipes = (querySnapshot?.documents.compactMap {
                return try? $0.data(as: UserRecipe.self)
            })!

            completion(true, self.recipes)
        }
    }

    init(userID: String) {
        self.userID = userID
        self.recipes = [UserRecipe]()
    }
}

class UserRecipe: Codable, Equatable, Identifiable, ObservableObject {
    enum CodingKeys: CodingKey {
        case recipeName, recipeURI, totalNutrients, totalDaily, calories, yeild
    }

    var id = UUID()
    var recipeName: String
    var recipeURI: String
    var totalNutrients: [NutrientInfo]
    var totalDaily: [NutrientInfo]
    var calories: Float
    var yeild: Float

    @Published var loadedImage: Image?

    var encodedURI: String {
        self.recipeURI.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    init(recipeName: String, recipeURI: String, totalNutrients: [NutrientInfo], totalDaily: [NutrientInfo], calories: Float, yeild: Float) {
        self.recipeName = recipeName
        self.recipeURI = recipeURI
        self.totalNutrients = totalNutrients
        self.totalDaily = totalDaily
        self.calories = calories
        self.yeild = yeild
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        recipeName = try container.decode(String.self, forKey: .recipeName)
        recipeURI = try container.decode(String.self, forKey: .recipeURI)
        totalNutrients = try container.decode([NutrientInfo].self, forKey: .totalNutrients)
        totalDaily = try container.decode([NutrientInfo].self, forKey: .totalDaily)
        calories = try container.decode(Float.self, forKey: .calories)
        yeild = try container.decode(Float.self, forKey: .yeild)
        GetImageFromStorage()
    }

    func GetImageFromStorage() {
        let ref = Storage.storage().reference()
        let recipeImageRef = ref.child("images/\(encodedURI).jpg")

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

    static func ==(lhs: UserRecipe, rhs: UserRecipe) -> Bool {
        return lhs.recipeURI == rhs.recipeURI
    }
}

struct UserRating {
    var recipeURI: String
    var rating: Int
}
