//
//  MealPrepWeekView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/2/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Grid

struct RecipeSelector: View {
    @EnvironmentObject var user: AppUser
    @Binding var selected: [ImportedRecipe]
    var recipes: [ImportedRecipe]

    var body: some View {
        GeometryReader { geo in
            if self.recipes.count > 0 {
                ScrollView {
                    Grid(0 ..< self.recipes.count) { index in
                        ZStack {

                            VStack(alignment: .center) {
                                Button(action: {
                                    if self.selected.contains(self.recipes[index]) {
                                        self.selected.remove(object: self.recipes[index])
                                    } else {
                                        self.selected.append(self.recipes[index])
                                    }
                                }) {
                                    RecipeGridItemContent(recipe: self.recipes[index], cloudCache: self.user.cloudImageCache)
                                }
                            }
                            .padding()

                            Image(systemName: (self.selected.contains(self.recipes[index])) ? "checkmark.circle" : "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.075)
                                .foregroundColor(.white)
                                .background(Color.green.clipShape(Circle()))
                                .padding(.leading, geo.size.width * 0.3)
                                .padding(.bottom, geo.size.width * 0.40)

                        }
                    }
                }
                .gridStyle(ModularGridStyle(columns: 2, rows: .fixed(230)))
            } else {

                VStack {
                    Spacer()

                    Text("Your favorite recipes")
                        .font(.headline)
                        .padding(.bottom, 10)

                    Text("Save recipes you love so that you can cook them again, and again, and again.")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Spacer()
                }
            }
        }
    }
}
