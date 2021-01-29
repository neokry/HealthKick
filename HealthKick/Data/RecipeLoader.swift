//
//  RecipeLoader.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/29/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import Alamofire
import FirebaseAuth

class RecipeLoader: ObservableObject {
    @Published var recipe: RecipeDetail?

    init(recipe: ImportedRecipe) {
        getRecipeFromURI(recipe: recipe)
    }

    struct RecipeRequestData: Codable {
        var title: String
        var yield: String = "4 servings"
        var ingr: [String]
        var prep: String
        var url: String
        var summary: String
    }

    struct RecipeRequest: Codable {
        let title: String
        let ingr: [String]
    }

    func getRecipeFromURI(recipe: ImportedRecipe) {
        let urlString = "https://api.edamam.com/api/nutrition-details?app_key=1f5ef194a95281eead7ce16c616685a3&app_id=4e352e2f"
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        URLCache.shared.removeCachedResponse(for: urlRequest)

        let parameters: [String: [String]] = [
            "title": [recipe.title],
            "ingr": recipe.ingredientsString
        ]

        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else {
                        return
                    }

                    var decodedResponse = try JSONDecoder().decode(RecipeDetail.self, from: data)
                    decodedResponse.info = recipe

                    DispatchQueue.main.async {
                        self.recipe = decodedResponse
                    }
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let err):
                print(err)
            }
        }
    }

    func getRecipeFromURI2(recipe: ImportedRecipe) {
        let urlString = "https://api.edamam.com/api/nutrition-details?app_key=1f5ef194a95281eead7ce16c616685a3&app_id=4e352e2f&force"
        let url = URL(string: urlString)

        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("route=c29c9ae5b3764707c25e6ff88ea0bd2f", forHTTPHeaderField: "Cookie")

        let body = RecipeRequest(title: recipe.title, ingr: recipe.ingredientsString)

        guard let uploadData = try? JSONEncoder().encode(body) else {
            return
        }

        request.httpBody = uploadData

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    var decodedResponse = try JSONDecoder().decode(RecipeDetail.self, from: data)
                    decodedResponse.info = recipe

                    DispatchQueue.main.async {
                        self.recipe = decodedResponse
                    }
                } catch {
                    print("Error decoding JSON \(error.localizedDescription)")
                }
            }
        }.resume()

    }
}

struct RecipeDetail: Codable {
    enum CodingKeys: CodingKey {
        case uri, yield, calories, dietLabels, healthLabels, cautions, totalNutrients
    }

    var uri: String
    var yield: Float
    var calories: Float
    var dietLabels: [String]
    var healthLabels: [String]
    var cautions: [String]
    var totalNutrients: [String: NutrientInfo]
    var info: ImportedRecipe?

    var friendlyCalories: Float {
        return calories / yield
    }

    var friendlyFat: Float {
        return totalNutrients["FAT"]!.quantity / yield
    }

    var friendlyCarb: Float {
        return totalNutrients["CHOCDF"]!.quantity / yield
    }

    var friendlyProtien: Float {
        return totalNutrients["PROCNT"]!.quantity / yield
    }
}
