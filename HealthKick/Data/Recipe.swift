//
//  Recipe.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/25/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import SwiftUI

struct searchResult: Codable {
    var more: Bool
    var hits: [searchHit]
}

struct searchHit: Codable, Identifiable {
    let id = UUID()
    var recipe: Recipe
}

class Recipe: Identifiable, Codable, Equatable, ObservableObject {
    enum CodingKeys: CodingKey {
        case uri, label, image, url, yield, dietLabels, healthLabels, cautions, calories, totalTime, ingredientLines, ingredients, totalNutrients, totalDaily
    }

    var id = UUID()
    var uri: String
    var label: String
    var image: String
    var url: String
    var yield: Float
    var dietLabels: [String]
    var healthLabels: [String]
    var cautions: [String]
    var calories: Float
    var totalTime: Float
    var ingredientLines: [String]
    var ingredients: [Ingredient]
    var totalNutrients: [String: NutrientInfo]
    var totalDaily: [String: NutrientInfo]

    @Published var isFavorite = false

    var encodedURI: String {
        self.uri.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var imageURL: URL? {
        if let imgURL = URL(string: image) {
            return imgURL
        } else {
            return nil
        }
    }

    var friendlyTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: TimeInterval(totalTime * 60))!
    }

    var friendlyDailyNutrients: [NutrientInfo] {
        var infoList = [NutrientInfo]()
        if let fat = totalDaily["FAT"] { infoList.append(fat) }
        if let carbs = totalDaily["CHOCDF"] { infoList.append(carbs) }
        if let protein = totalDaily["PROCNT"] { infoList.append(protein) }

        if let fiber = totalDaily["FIBTG"] { infoList.append(fiber) }
        if let sugar = totalDaily["SUGAR"] { infoList.append(sugar) }
        if let cholesterol = totalDaily["CHOLE"] { infoList.append(cholesterol) }
        if let sodium = totalDaily["NA"] { infoList.append(sodium) }
        return infoList
    }

    var friendlyTotalNutrients: [NutrientInfo] {
        var infoList = [NutrientInfo]()
        if let fat = totalNutrients["FAT"] { infoList.append(fat) }
        if let carbs = totalNutrients["CHOCDF"] { infoList.append(carbs) }
        if let protein = totalNutrients["PROCNT"] { infoList.append(protein) }

        if let fiber = totalNutrients["FIBTG"] { infoList.append(fiber) }
        if let sugar = totalNutrients["SUGAR"] { infoList.append(sugar) }
        if let cholesterol = totalNutrients["CHOLE"] { infoList.append(cholesterol) }
        if let sodium = totalNutrients["NA"] { infoList.append(sodium) }
        return infoList
    }

    var friendlyCalories: Float {
        return calories / Float(yield)
    }

    var friendlyFat: Float {
        return totalNutrients["FAT"]!.quantity / Float(yield)
    }

    var friendlyCarb: Float {
        return totalNutrients["CHOCDF"]!.quantity / Float(yield)
    }

    var friendlyProtien: Float {
        return totalNutrients["PROCNT"]!.quantity / Float(yield)
    }

    static func ==(lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.uri == rhs.uri
    }

}

struct Ingredient: Codable {
    var text: String
    var quantity: Float
    var measure: String?
    var food: String
    var weight: Float
    var foodCategory: String?
}

struct NutrientInfo: Codable, Hashable {
    var label: String
    var quantity: Float
}

struct Recommendations: Codable, Hashable {
    var exampleIngredients: [String]
    var exampleRecipes: [String]
}
