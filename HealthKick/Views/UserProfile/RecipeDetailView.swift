//
//  RecipeDetail.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/27/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var user: AppUser
    @State private var showWebview = false
    var recipe: RecipeDetail
    var geo: GeometryProxy
    var loadedImage: Image?
    var hasRecipe: Bool {
        return user.userRecipes?.first(where: { $0.id == recipe.info?.id }) != nil
    }

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section {
                        HStack {
                            if loadedImage != nil {
                                loadedImage!
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 160, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            RecipeTags(recipe: recipe)
                        }
                        .frame(width: geo.size.width * 0.9, height: 180)
                        .detailGroupStyle(width: geo.size.width)
                        .padding(.top, 10)
                    }

                    Section {
                        RecipeNutrients(recipe: recipe)
                            .frame(width: geo.size.width * 0.9, height: 100)
                            .detailGroupStyle(width: geo.size.width)
                    }

                    Section {
                        VStack(alignment: .leading) {
                            ForEach(recipe.info!.ingredientsString, id: \.self) { ingredient in
                                Text(ingredient)
                                    .font(.subheadline)
                                    .padding()
                            }
                            .frame(width: geo.size.width * 0.9)
                        }
                        .detailGroupStyle(width: geo.size.width)
                        .padding(.bottom, 65)
                    }
                }

                RecipeDetailControls(showWebview: self.$showWebview, presentationMode: presentationMode, geo: self.geo, url: self.recipe.info!.url ?? "", hasRecipe: self.hasRecipe, recipe: self.recipe.info!)
            }
            .navigationBarTitle(Text(recipe.info!.title), displayMode: .inline)
        }
    }
}

struct RecipeDetailControls: View {
    @EnvironmentObject var user: AppUser
    @Binding var showWebview: Bool
    @Binding var presentationMode: PresentationMode
    @State var confirmDelete = false
    var geo: GeometryProxy
    var url: String
    var hasRecipe: Bool
    var recipe: ImportedRecipe

    var body: some View {
        HStack {
            Button(action: {
                if self.hasRecipe {
                    self.confirmDelete = true
                }else{
                    RecipeClient().SaveRecipe(recipe: self.recipe, completion: {})
                }
            }) {
                HStack {
                    Text(hasRecipe ? "Delete" : "Save")
                    Image(systemName: hasRecipe ? "trash" : "heart")
                }
                .font(.subheadline)
                .padding([.leading, .trailing], 25)
                .padding([.top, .bottom], 10)
                .foregroundColor(.white)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)
            }
            .padding()

            Button(action: {
                self.showWebview = true
            }) {
                NavigationLink(destination: WebView(urlString: url)
                    .edgesIgnoringSafeArea(.all)
                ) {
                    HStack {
                        Text("View")
                        Image(systemName: "doc")
                    }
                    .font(.subheadline)
                    .padding([.leading, .trailing], 25)
                    .padding([.top, .bottom], 10)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 5)
                }
            }
            .padding()
        }
        .padding(.top, geo.size.height * 0.87)
        .alert(isPresented: self.$confirmDelete) {
            Alert(title: Text("Confirm"), message: Text("Are you sure you want to delete this recipe?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: {
                self.presentationMode.dismiss()
                RecipeClient().DeleteRecipe(recipeID: self.recipe.id){ success in
                    if success {
                        self.user.userRecipes?.remove(object: self.recipe)
                    }
                }
            }))
        }
    }
}
