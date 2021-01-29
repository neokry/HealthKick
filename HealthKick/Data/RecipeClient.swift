//
//  RecipeBuilder.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/30/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class RecipeClient {
    func RecipeFromURL(url: String, completion: @escaping (Bool, ImportedRecipe?) -> Void) {
        let searchURL = "https://health-kick-a3832.uc.r.appspot.com/?url=" + url
        CallAPI(from: searchURL) { result in
            switch result {
            case .failure(let err):
                print("Error getting recipe \(err)")
                completion(false, nil)
            case .success(let JSON):
                if let data = JSON.data(using: String.Encoding.utf8) {
                    do {
                        let recipeImport = try JSONDecoder().decode(ImportedRecipe.self, from: data)
                        completion(true, recipeImport)
                    } catch {
                        print("Error decoding JSON data \(error.localizedDescription)")
                        completion(false, nil)
                    }
                }
            }
        }
    }

    func LoadRecipes(completion: @escaping (Bool, [ImportedRecipe]?) -> Void) {
        guard let user =  Auth.auth().currentUser else {
            fatalError("No user set")
        }

        let db = Firestore.firestore()
        let recipeRef = db.collection("userRecipes").document(user.uid).collection("recipes")

        recipeRef.getDocuments { snap, err in
            if let err = err {
                print("Error loading recipes \(err)")
                completion(false, nil)
                return
            }
            let temp = (snap?.documents.compactMap {
                 try? $0.data(as: ImportedRecipe.self)
             })!
            completion(true, temp)
        }
    }

    func UpdateRecipe(recipe: ImportedRecipe, user: User) {
        let db = Firestore.firestore()
        do {
            let recipeRef = db.collection("userRecipes").document(user.uid).collection("recipes").document(recipe.id)
            try recipeRef.setData(from: recipe, merge: true) { err in
                if let err = err {
                    print("Error saving recipe \(err)")
                }
            }
        } catch {
            print("Error saving recipe \(error.localizedDescription)")
        }
    }

    func SaveRecipe(recipe: ImportedRecipe, img: UIImage? = nil, completion: @escaping () -> Void) {
        guard let user =  Auth.auth().currentUser else {
            fatalError("No user set")
        }

        if let img = img {
            SaveImageInStorage(recipeID: recipe.id, img: img) { success in
                if success {
                    self.SaveRecipeToDB(recipe: recipe, user: user) {
                        completion()
                    }
                }
            }
        } else {
            self.SaveRecipeToDB(recipe: recipe, user: user) {
                completion()
            }
        }
    }

    func DeleteRecipe(recipeID: String, completion: @escaping (Bool) -> Void) {
        guard let user =  Auth.auth().currentUser else {
            fatalError("No user set")
        }

        let db = Firestore.firestore()
        let recipeRef = db.collection("userRecipes").document(user.uid).collection("recipes").document(recipeID)
        recipeRef.delete { err in
            if let err = err {
                print("Error deleting recipe \(err)")
                completion(false)
                return
            }
            
            completion(true)
        }
    }

    private func SaveRecipeToDB(recipe: ImportedRecipe, user: User, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        do {
            let recipeRef = db.collection("userRecipes").document(user.uid).collection("recipes").document(recipe.id)
            try recipeRef.setData(from: recipe) { err in
                if let err = err {
                    print("Error saving recipe \(err)")
                }
            }
        } catch {
            print("Error saving recipe \(error.localizedDescription)")
        }
    }

    private func SaveImageInStorage(recipeID: String, img: UIImage, completion: @escaping (Bool) -> Void) {
        let ref = Storage.storage().reference()
        let recipeImageRef = ref.child("images/\(recipeID).jpg")

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

struct ImportedRecipe: Codable, Equatable {
    var id: String
    var url: String?
    var etag: String?
    var title: String
    var description: String
    var ingredients: [RecipeImporterIngredients]
    var instructions: [String]
    var image: String
    var imageURL: URL? {
        return URL(string: image)
    }

    var ingredientsString: [String] {
        var ingList = [String]()
        for ing in ingredients {
            var result = ing.line

            var split = result.split(separator: "(", maxSplits: 1)
            if split.count > 1 {
                split[1].removeAll(where: { $0 == "(" })
                result = String(split[0] + "(" + split[1])
            }

            split = result.split(separator: ")", maxSplits: 1)
            if split.count > 1 {
                split[1].removeAll(where: { $0 == ")" })
                result = String(split[0] + ")" + split[1])
            }

            ingList.append(result)
        }
        return ingList
    }

    enum CodingKeys: CodingKey {
        case id, url, etag, title, description, ingredients, instructions, image
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        url = try container.decodeIfPresent(String.self, forKey: .url)
        etag = try container.decodeIfPresent(String.self, forKey: .etag)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        ingredients = try container.decode([RecipeImporterIngredients].self, forKey: .ingredients)
        instructions = try container.decode([String].self, forKey: .instructions)
        image = try container.decode(String.self, forKey: .image)
    }

    init() {
        self.id = UUID().uuidString
        self.title = ""
        self.description = ""
        self.ingredients = [RecipeImporterIngredients]()
        self.instructions = [String]()
        self.image = ""
    }

    static func ==(lhs: ImportedRecipe, rhs: ImportedRecipe) -> Bool {
        return lhs.id == rhs.id
    }

}

struct RecipeImporterIngredients: Codable, Hashable {
    var line: String
}
