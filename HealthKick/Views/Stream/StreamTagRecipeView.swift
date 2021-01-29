//
//  StreamTagRecipeView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/13/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Grid

struct StreamTagRecipeView: View {
    @EnvironmentObject var user: AppUser
    @Environment(\.presentationMode) var presentationMode
    @Binding var selected: ImportedRecipe?
    var recipes: [ImportedRecipe]

    var body: some View {
        GeometryReader { geo in
            if self.recipes.count > 0 {
                ScrollView {
                    Grid(0 ..< self.recipes.count) { index in
                        ZStack {
                            VStack(alignment: .center) {
                                Button(action: {
                                    self.selected = self.recipes[index]
                                    self.presentationMode.wrappedValue.dismiss()
                                }) {
                                    RecipeGridItemContent(recipe: self.recipes[index], cloudCache: self.user.cloudImageCache)
                                }
                            }
                            .padding()
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
    }
}
