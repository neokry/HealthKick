//
//  GroceryListView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/25/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct UserGroceryListView: View {
    @EnvironmentObject var user: AppUser

    var body: some View {
        NavigationView {
            if user.userGroceryList != nil {
                GroceryListView(groceryList: user.userGroceryList!)
            } else {
                EmptyView()
            }
        }
    }
}

struct GroceryListView: View {
    @EnvironmentObject var user: AppUser
    @ObservedObject var groceryList: UserGroceryList
    @State var addRecipes = false
    @State var recipes = [ImportedRecipe]()

    var body: some View {
        Group {
            if groceryList.groceryItems.count > 0 {
                List {
                    ForEach(self.groceryList.groceryItems) { groceryItem in
                        GroceryListItemView(groceryItem: groceryItem, groceryList: self.groceryList)
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                VStack {
                    Spacer()

                    Text("Your grocery list, organized")
                        .font(.headline)
                        .padding(.bottom, 10)

                    Text("All the ingredients you need for the week are organized into an easy-to-use grocery list. Shopping has never been easier.")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Spacer()
                }
            }

            NavigationLink(destination: RecipeSelector(selected: self.$recipes, recipes: user.userRecipes ?? [ImportedRecipe]()).onDisappear(perform: {
                self.groceryList.GenerateGroceryList(recipes: self.recipes)
            }), isActive: $addRecipes) {
                EmptyView()
            }
        }
        .navigationBarTitle("Grocery List", displayMode: .inline)
        .navigationBarItems(leading: Button("Clear") {
                self.groceryList.ClearList()
            }, trailing: Button("Create") {
                self.addRecipes = true
            }
        )
    }
}

struct GroceryListItemView: View {
    @ObservedObject var groceryItem: GroceryItem
    @ObservedObject var groceryList: UserGroceryList

    var body: some View {
        Button(action: {
            self.groceryItem.selected = true
            self.groceryList.SaveList()
        }) {
            HStack {
                Image(systemName: groceryItem.selected ? "checkmark.circle" : "circle")
                    .renderingMode(.original)
                Text(groceryItem.ingredient)

            }
            .foregroundColor(.black)
        }
    }

    func getFraction(x0: Double, withPrecision eps: Double = 1.0E-3) -> String {
        var x = x0.truncatingRemainder(dividingBy: 1)

        if x > 0 {
            var a = floor(x)
            var (h1, k1, h, k) = (1, 0, Int(a), 1)

            while x - a > eps * Double(k) * Double(k) {
                x = 1.0/(x - a)
                a = floor(x)
                (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
            }
            return "\(floor(x0) > 0 ? String(format: "%.0f", floor(x0)) : "") \(h)/\(k) "
        } else if x0 > 0 {
            return "\(Int(floor(x0))) "
        } else {
            return ""
        }

    }
}
