//
//  File.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/26/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation

public enum diet: String, CaseIterable, Codable {
    case vegan = "Vegan"
    case vegetarian = "Vegitarian"
    case keto = "Keto"
    case paleo = "Paleo"
    case kosher = "Kosher"
    case pescatarian = "Pescatarian"
}

public enum allergies: String, CaseIterable, Codable {
    case fish = "Fish-Free"
    case eggs = "Egg-Free"
    case dairy = "Dairy-Free"
    case alcohol = "Alcohol-Free"
    case peanuts = "Peanut-Free"
    case glutenFree = "Gluten-Free"
}

public enum prefrences: String, CaseIterable, Codable {
    case balanced
    case highFiber
    case highProtine
    case lowCarb
    case lowFat
    case lowSodium
    case redMeatFree
    case wheatFree
}

public enum mealType: String, CaseIterable, Codable {
    case breakfast
    case lunch
    case dinner
    case snack
    case dessert
    case drink
}

class Filter: ObservableObject, Codable {
    @Published var selectedDiet: diet?
    @Published var selectedAllergies: [allergies]
    @Published var selectedPrefrences: [prefrences]
    @Published var selectedMealType: [mealType]
    var filterString: String {
        var temp = ""

        switch selectedDiet {
        case .vegan:
            temp += "&health=vegan"
        case .vegetarian:
            temp += "&health=vegetarian"
        case .keto:
            temp += "&health=keto-friendly"
        case .paleo:
            temp += "&health=paleo"
        case .kosher:
            temp += "&health=kosher"
        case .pescatarian:
            temp += "&health=pescatarian"
        case .none:
            break
        }

        for allergy in selectedAllergies {
            switch allergy {
            case .alcohol:
                temp += "&health=alcohol-free"
            case .dairy:
                temp += "&health=dairy-free"
            case .eggs:
                temp += "&health=egg-free"
            case .fish:
                temp += "&health=fish-free"
            case .glutenFree:
                temp += "&health=gluten-free"
            case .peanuts:
                temp += "&health=peanut-free"
            }
        }

        return temp
    }

    enum CodingKeys: CodingKey {
        case selectedDiet, selectedAllergies, selectedPrefrences, selectedMealType
    }

    init() {
        selectedDiet = nil
        selectedAllergies = [allergies]()
        selectedPrefrences = [prefrences]()
        selectedMealType = [mealType]()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(selectedDiet, forKey: .selectedDiet)
        try container.encode(selectedAllergies, forKey: .selectedAllergies)
        try container.encode(selectedPrefrences, forKey: .selectedPrefrences)
        try container.encode(selectedMealType, forKey: .selectedMealType)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        selectedDiet = try container.decode(diet?.self, forKey: .selectedDiet)
        selectedAllergies = try container.decode([allergies].self, forKey: .selectedAllergies)
        selectedPrefrences = try container.decode([prefrences].self, forKey: .selectedPrefrences)
        selectedMealType = try container.decode([mealType].self, forKey: .selectedMealType)
    }
}
