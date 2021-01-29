//
//  RecipiesView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/25/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Grid

struct UserRecipesView: View {
    @EnvironmentObject var user: AppUser

    var body: some View {
        ZStack {
            Group {
                if self.user.userRecipes != nil && self.user.userRecipes!.count > 0 {
                    RecipesGrid(userRecipes: self.user.userRecipes!)
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
            .animation(nil)

        }
    }
}

struct RecipesGrid: View {
    var userRecipes: [ImportedRecipe]
    let rows: Int

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                Grid(0 ..< self.userRecipes.count) { index in
                    RecipesGridItem(recipe: self.userRecipes[index], width: geo.size.width, height: geo.size.height)
                }
            }.gridStyle(ModularGridStyle(columns: 2, rows: .fixed(230)))
        }
    }

    init(userRecipes: [ImportedRecipe]) {
        self.userRecipes = userRecipes
        self.rows = Int(round(Double(userRecipes.count)/2))
    }

}

struct RecipesGridItem: View {
    @Environment(\.imageCache) var imageCache
    var recipe: ImportedRecipe
    var width: CGFloat
    var height: CGFloat
    var showDetails = true
    @EnvironmentObject var user: AppUser
    @State private var showSheet = false

    var loadedImage: UIImage? {
        if let img = user.cloudImageCache[recipe.id] {
            return img
        } else if let url = recipe.imageURL {
            if let img = imageCache[url] {
                return img
            }
        }

        return nil
    }

    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                self.showSheet = self.showDetails
            }) {
                RecipeGridItemContent(recipe: recipe, cloudCache: user.cloudImageCache)
            }
        }
        .padding()
        .sheet(isPresented: $showSheet) {
            RecipeDetailLoader(recipe: self.recipe, loadedImage: self.loadedImage != nil ? Image(uiImage: self.loadedImage!) : nil)
                .environmentObject(self.user)
        }

    }

}

struct RecipeGridItemContent: View {
    @Environment(\.imageCache) var imageCache
    @State var loaded = false
    var cloudCache: [String: UIImage]
    var recipe: ImportedRecipe
    let size: CGFloat = 160

    var body: some View {
        VStack {
            if cloudCache[recipe.id] != nil {
                Image(uiImage: cloudCache[recipe.id]!)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 10)
            } else {
                if recipe.imageURL != nil {
                    AsyncImage(url: recipe.imageURL!, cache: self.imageCache, placeholder: ImagePlacerHolder())
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 10)
                } else {
                    Image("icon.square")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 10)
                }
            }

            Text(recipe.title)
                .minimumScaleFactor(0.9)
                .truncationMode(.tail)
                .foregroundColor(.primary)
                .font(.subheadline)
                .frame(height: 40)
        }
    }

    init(recipe: ImportedRecipe, cloudCache: [String: UIImage]) {
        self.cloudCache = cloudCache
        self.recipe = recipe
    }
}

struct RecipesView_Previews: PreviewProvider {
    static var previews: some View {
        UserRecipesView()
    }
}
