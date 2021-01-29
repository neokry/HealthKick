//
//  GroceryListAddRecipesView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/21/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Grid

struct GroceryListAddRecipesView: View {
    @EnvironmentObject var user: AppUser
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var groceryList: UserGroceryList
    var recipes: [ImportedRecipe]

    var body: some View {
        GeometryReader { geo in
            if self.recipes.count > 0 {
                ScrollView {
                    Grid(0 ..< self.recipes.count) { index in
                        ZStack {
                            VStack(alignment: .center) {
                                Button(action: {
                                    if self.groceryList.selected.contains(self.recipes[index]) {
                                        self.groceryList.selected.remove(object: self.recipes[index])
                                    } else {
                                        self.groceryList.selected.append(self.recipes[index])
                                    }
                                }) {
                                    RecipeGridItemContent(recipe: self.recipes[index], cloudCache: self.user.cloudImageCache)
                                }
                            }
                            .padding()

                            Image(systemName: (self.groceryList.selected.contains(self.recipes[index])) ? "checkmark.circle" : "plus.circle.fill")
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
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                    Text("No recipes added")
                        .foregroundColor(.white)
                        .fontWeight(.black)
                }
                .padding(20)
                .background(Color.green)
                .frame(width: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 5)
                .padding([.top, .bottom], geo.size.height * 0.25)
                .padding(.leading, geo.size.width * 0.25)
            }
        }
        .navigationBarItems(trailing: Button("Save") {
            self.groceryList.GenerateGroceryList()
            self.presentationMode.wrappedValue.dismiss()
        })
    }
}
