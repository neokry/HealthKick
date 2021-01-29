//
//  RecipeDetailError.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/1/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Foundation

struct RecipeDetailLoader: View {
    @EnvironmentObject var user: AppUser
    @ObservedObject var recipeLoader: RecipeLoader
    var loadedImage: Image?

    var body: some View {
        GeometryReader { geo in
            VStack {
                if self.recipeLoader.recipe != nil {
                    RecipeDetailView(recipe: self.recipeLoader.recipe!, geo: geo, loadedImage: self.loadedImage)
                } else {
                    Text("Loading...")
                }
            }
        }
    }

    init(recipe: ImportedRecipe, loadedImage: Image?) {
        recipeLoader = RecipeLoader(recipe: recipe)
        self.loadedImage = loadedImage
    }

}
