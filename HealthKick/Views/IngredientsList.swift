//
//  IngredientsList.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/27/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct IngredientsList: View {
    var ingredientList: [String]
    var body: some View {
        List(ingredientList, id: \.self) { ingredient in
            Text(ingredient)
        }
    }
}
