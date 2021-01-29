//
//  MealPrepWeekView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/2/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct MealPrepAddRecipesView: View {
    @Binding var selected: [UserRecipe]
    var recipes: [UserRecipe]

    var body: some View {
        GeometryReader { geo in
            List(self.recipes, id: \.self) { recipe in
                ZStack {
                    RecipesGridItem(recipe: recipe, width: geo.size.width, height: geo.size.height)
                    Button(action: {
                        self.selected.append(recipe)
                    }) {
                        Image(systemName: (self.selected.contains(recipe)) ? "checkmark.square" : "square")
                            .padding(.leading, geo.size.width * 0.8)
                    }
                }

            }
        }
    }
}
