//
//  UserGroceryList.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/21/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class UserGroceryList: ObservableObject, Codable {
    @Published var groceryItems: [GroceryItem] = [GroceryItem]()
    var userID: String
    let db = Firestore.firestore()

    enum CodingKeys: CodingKey {
        case groceryItems, userID
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(groceryItems, forKey: .groceryItems)
        try container.encode(userID, forKey: .userID)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        groceryItems = try container.decode([GroceryItem].self, forKey: .groceryItems)
        userID = try container.decode(String.self, forKey: .userID)
    }

    func GenerateGroceryList(recipes: [ImportedRecipe]) {
        for recipe in recipes {
            for ing in recipe.ingredients {
                let item = GroceryItem(ingredient: ing.line)
                self.groceryItems.append(item)
            }
        }
        self.SaveList()
    }

    /*
    func GenerateGroceryListOld() {
        let uriString = ""
        
       // for recipe in selected {
            //uriString += "&r=" + recipe.id
        //}
        
        let url = URL(string: "https://api.edamam.com/search?\(uriString)&app_id=a00eda9b&app_key=f5b053c4344b7ecc3ff4ce50677fe981")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error requesting reccomendations from api, \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do{
                    let decodedResponse = try JSONDecoder().decode([Recipe].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.sections = [GrocerySection]()
                        var ingredients = [Ingredient]()
                        for recipe in decodedResponse {
                            for ingredient in recipe.ingredients {
                                if let section = self.sections.first(where: { $0.sectionName == ingredient.foodCategory }) {
                                    section.items.append(GroceryItem(ingredient: ingredient))
                                } else {
                                    let section = GrocerySection(sectionName: ingredient.foodCategory ?? "No Category")
                                    section.items.append(GroceryItem(ingredient: ingredient))
                                    self.sections.append(section)
                                }
                                ingredients.append(ingredient)
                            }
                        }
                        
                        self.SaveList()
                        //Analytics.logEvent("made_grocery_list", parameters: ["recipe_count": self.selected.count])
                        //self.selected = [ImportedRecipe]()
                        
                        return
                    }
                    
                }catch {
                    print("Error")
                    Crashlytics.crashlytics().log("Error creating grocery list \(error.localizedDescription)")
                    return
                }
            }
        }.resume()
    }
    */
    func ClearList() {
        self.groceryItems = [GroceryItem]()
        SaveList()
    }

    func SaveList() {
        do {
            let listRef = db.collection("userGroceryList").document(userID)
            try listRef.setData(from: self, merge: true) { err in
                if let err = err {
                    print("Error saving grocery list, \(err)")
                }
            }
        } catch {
            print("Error saving grocery list, \(error.localizedDescription)")
            Crashlytics.crashlytics().log("Error saving grocery list, \(error.localizedDescription)")
        }
    }

    init(userID: String) {
        self.userID = userID
        db.collection("userGroceryList").document(userID).getDocument { (doc, err) in
            if let err = err {
                print("Error getting grocery list \(err.localizedDescription)")
                return
            }
            do {
                if let data = try doc?.data(as: UserGroceryList.self) {
                    self.groceryItems = data.groceryItems
                }
            } catch {
                print("Error getting grocery list \(error.localizedDescription)")
                Crashlytics.crashlytics().log("Error getting grocery list \(error.localizedDescription)")
                return
            }

        }
    }
}

class GrocerySection: Identifiable, Codable {
    var id = UUID()
    var sectionName: String
    var items = [GroceryItem]()

    init(sectionName: String) {
        self.sectionName = sectionName
    }
}

class GroceryItem: Identifiable, ObservableObject, Codable {
    var id = UUID()
    @Published var selected: Bool
    var ingredient: String

    enum CodingKeys: CodingKey {
        case selected, ingredient
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(selected, forKey: .selected)
        try container.encode(ingredient, forKey: .ingredient)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        selected = try container.decode(Bool.self, forKey: .selected)
        ingredient = try container.decode(String.self, forKey: .ingredient)
    }

    init(ingredient: String) {
        self.selected = false
        self.ingredient = ingredient
    }
}
