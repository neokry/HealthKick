//
//  MealPrepDayRecipes.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/3/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Grid

struct MealPrepDayRecipes: View {
    var recipes: [UserRecipe]?
    @Binding var isAdd: Bool

    var body: some View {
        Group {
            GeometryReader { _ in
                if self.recipes != nil && (self.recipes?.count)! > 0 {
                    ScrollView {
                        Grid(0 ..< (self.recipes?.count)!) { _ in
                            EmptyView()
                            //RecipesGridItem(recipe: self.recipes![index], width: geo.size.width, height: geo.size.height)
                        }
                    }
                    .gridStyle(ModularGridStyle(columns: 2, rows: .fixed(230)))
                    .animation(self.isAdd ? .default : nil)
                } else {
                    HStack {
                        Spacer()

                        VStack {
                            Spacer()

                            Text("Your meal plan")
                                .font(.headline)
                                .padding(.bottom, 10)

                            Text("What's on your plate today?")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .padding(.bottom, 30)

                            Spacer()
                        }

                        Spacer()
                    }
                }
            }
        }
    }

}
