//
//  UserRecipeBuilder.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/30/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

enum BuilderType {
    case url, freeText
}

struct UserRecipeBuilderProperties {
    var recipeImg: UIImage?
    var index = 0
    var recipeURL = ""
    var ingredientsList = [String]()
    var instructionsList = [String]()
    var takePhoto = false
    var showImagePicker = false
    var importerResult = ImportedRecipe()
}

struct UserRecipeBuilder: View {
    @State private var props = UserRecipeBuilderProperties()
    @Environment(\.presentationMode) var presentationMode
    var builderType: BuilderType

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    if self.builderType == .url {
                        
                        RecipeBuilderHeaderURLView(geo: geo, index: self.$props.index)
                        
                        if self.props.index == 0 {
                            UserRecipeBuilderURLImport(props: self.$props, geo: geo)
                        } else if self.props.index == 1 {
                            UserRecipeBuilderLoadResults(props: self.$props, recipeURL: self.props.recipeURL, geo: geo)
                        } else if self.props.index == 2 {
                            UserRecipeBuilderIngredients(props: self.$props, geo: geo)
                        } else if self.props.index == 3 {
                            UserRecipeBuilderIconAndName(props: self.$props, geo: geo, isEnd: true)
                        } else if self.props.index == 4 {
                            UserRecipeBuilderSave(props: self.$props, presentationMode: self.presentationMode)
                        }
                    }else{
                        
                        RecipeBuilderHeaderTextView(geo: geo, index: self.$props.index)
                        
                        if self.props.index == 0 {
                            UserRecipeBuilderBulkIngredients(props: self.$props, geo: geo)
                        } else if self.props.index == 1 {
                            UserRecipeBuilderIconAndName(props: self.$props, geo: geo, isEnd: false)
                        } else if self.props.index == 2 {
                            UserRecipeBuilderDirections(props: self.$props, geo: geo)
                        }else if self.props.index == 3 {
                            UserRecipeBuilderSave(props: self.$props, presentationMode: self.presentationMode)
                        }
                    }

                    Spacer()
                }
            }
            .navigationBarTitle(" ")
            .navigationBarHidden(true)
        }
    }
}

struct RecipeBuilderHeaderTextView: View {
    var geo: GeometryProxy
    @Binding var index: Int
    var titles = ["Add some ingredients", "Add an icon and title", "Add some directions", "Saving recipe"]

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15)
                    .padding([.top, .trailing], 20)
            }

            Image("icon")
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * 0.3)
                .padding(5)

            Text(self.titles[self.index])
                .font(.title)
                .fontWeight(.light)

            HStack {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 30, height: 30)

                    Text("1")
                        .padding()
                        .foregroundColor(.white)
                }

                ZStack {
                    Circle()
                        .fill(self.index > 0 ? Color.green : Color.green.opacity(0.5))
                        .frame(width: 30, height: 30)

                    Text("2")
                        .padding()
                        .foregroundColor(.white)
                }

                ZStack {
                    Circle()
                        .fill(self.index > 2 ? Color.green : Color.green.opacity(0.5))
                        .frame(width: 30, height: 30)

                    Text("3")
                        .padding()
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct RecipeBuilderHeaderURLView: View {
    var geo: GeometryProxy
    @Binding var index: Int
    var titles = ["Lets get started", "Loading your recipe", "Verify ingredients", "Add an icon and title", "Saving recipe"]

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15)
                    .padding([.top, .trailing], 20)
            }

            Image("icon")
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * 0.3)
                .padding(5)

            Text(self.titles[self.index])
                .font(.title)
                .fontWeight(.light)

            HStack {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 30, height: 30)

                    Text("1")
                        .padding()
                        .foregroundColor(.white)
                }

                ZStack {
                    Circle()
                        .fill(self.index > 1 ? Color.green : Color.green.opacity(0.5))
                        .frame(width: 30, height: 30)

                    Text("2")
                        .padding()
                        .foregroundColor(.white)
                }

                ZStack {
                    Circle()
                        .fill(self.index > 2 ? Color.green : Color.green.opacity(0.5))
                        .frame(width: 30, height: 30)

                    Text("3")
                        .padding()
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct UserRecipeBuilderSaveFreeText: View {
    @Binding var props: UserRecipeBuilderProperties
    @Binding var presentationMode: PresentationMode

    var body: some View {
        LoadingView(text: "Saving your recipe")
        .onAppear(perform: {
            self.props.importerResult.instructions = self.props.instructionsList
            for ing in self.props.ingredientsList {
                let ingredient = RecipeImporterIngredients(line: ing)
                self.props.importerResult.ingredients.append(ingredient)
            }
            
            RecipeClient().SaveRecipe(recipe: self.props.importerResult, img: self.props.recipeImg) {
                self.presentationMode.dismiss()
            }
        })
    }
}

struct UserRecipeBuilderDirections: View {
    @Binding var props: UserRecipeBuilderProperties
    @State private var instruction = ""
    var geo: GeometryProxy
    
    var body: some View {
        VStack{
            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.92)
                
                HStack{
                    TextField("Preheat oven to 375", text: self.$instruction)
                        .padding(.horizontal, 25)
                    
                    Spacer()
                    
                    Button(action: {
                        self.props.instructionsList.append(self.instruction)
                        self.instruction = ""
                    }){
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.green.clipShape(Circle()))
                            .padding(.trailing, 25)
                    }
                }
            }
            
            List{
                ForEach(props.instructionsList, id: \.self) { instruction in
                    Text(instruction)
                }
            }
            
            Button(action: {
                self.props.index = 3
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.92, color: Color.green)

                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                }
            }
        }
    }
}

struct UserRecipeBuilderBulkIngredients: View {
    @Binding var props: UserRecipeBuilderProperties
    @State private var ingredient = ""
    var geo: GeometryProxy
    
    var body: some View {
        VStack{
            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.92)
                
                HStack{
                    TextField("8 oz of penne pasta", text: self.$ingredient)
                        .autocapitalization(.none)
                        .padding(.horizontal, 25)
                    
                    Spacer()
                    
                    Button(action: {
                        self.props.ingredientsList.insert(self.ingredient, at: 0)
                        self.ingredient = ""
                    }){
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.green.clipShape(Circle()))
                            .padding(.trailing, 25)
                    }
                }
            }
            
            List{
                ForEach(props.ingredientsList, id: \.self) { ingredient in
                    Text(ingredient)
                }
            }
            
            Button(action: {
                self.props.index = 1
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.92, color: Color.green)

                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                }
            }
        }
    }
}

struct UserRecipeBuilderURLImport: View {
    @Binding var props: UserRecipeBuilderProperties
    var geo: GeometryProxy

    var body: some View {
        VStack {
            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.92)

                TextField("Recipe URL", text: self.$props.recipeURL)
                    .autocapitalization(.none)
                    .padding(.horizontal, 25)
            }

            Button(action: {
                self.hideKeyboard()
                self.props.index = 1
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.92, color: Color.green)

                    Text("Import")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                }
            }
        }
    }
}

struct UserRecipeBuilderLoadResults: View {
    @Binding var props: UserRecipeBuilderProperties
    var recipeURL: String
    var geo: GeometryProxy

    var body: some View {
        VStack {
            LoadingView(text: "Importing")
        }
        .onAppear(perform: {
            RecipeClient().RecipeFromURL(url: self.recipeURL) { success, result in
                if success {
                    self.props.importerResult = result!
                    self.props.index += 1
                }
            }
        })
    }
}

struct UserRecipeBuilderIngredients: View {
    @Binding var props: UserRecipeBuilderProperties
    var geo: GeometryProxy

    var body: some View {
        VStack {
            List {
                ForEach(props.importerResult.ingredients, id: \.self) { ing in
                    Text(ing.line)
                }
                .onDelete(perform: { offset in
                    self.props.importerResult.ingredients.remove(atOffsets: offset)
                })
            }

            Button(action: {
                self.hideKeyboard()
                self.props.index = 3
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.92, color: Color.green)

                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                }
            }
        }
    }
}

struct UserRecipeBuilderIconAndName: View {
    @Environment(\.imageCache) var cache: ImageCache
    @Binding var props: UserRecipeBuilderProperties
    @State private var title: String = ""
    var geo: GeometryProxy
    var isEnd: Bool

    var body: some View {
        VStack {

            Spacer()

            Group {
                if self.props.recipeImg == nil {
                    if self.props.importerResult.imageURL != nil {
                        AsyncImage(url: self.props.importerResult.imageURL!, cache: self.cache, placeholder: ImagePlacerHolder(text: "Tap to select an icon"))
                            .scaledToFill()
                            .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color("LoadingBackgroundColor"))
                                .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)

                            Text("Tap to select an icon")
                                .foregroundColor(Color.gray.opacity(0.4))
                        }
                    }
                } else {
                    Image(uiImage: self.props.recipeImg!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                        .allowsHitTesting(false)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                 }
            }
            .onTapGesture {
                self.props.showImagePicker = true
            }

            Spacer()

            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.92)

                TextField("Recipe name", text: self.$title)
                    .padding(.horizontal, 25)
            }

            Button(action: {
                self.props.importerResult.title = self.title
                self.props.index += 1
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.92, color: Color.green)

                    Text(isEnd ? "Finish" : "Continue")
                        .foregroundColor(.white)
                }
            }

            Spacer()

        }
        .sheet(isPresented: self.$props.showImagePicker) {
            ImagePicker(image: self.$props.recipeImg, takePhoto: self.$props.takePhoto)
        }
    }
}

struct UserRecipeBuilderSave: View {
    @Binding var props: UserRecipeBuilderProperties
    @Binding var presentationMode: PresentationMode

    var body: some View {
        LoadingView(text: "Saving your recipe")
        .onAppear(perform: {
            RecipeClient().SaveRecipe(recipe: self.props.importerResult, img: self.props.recipeImg) {
                self.presentationMode.dismiss()
            }
        })
    }
}
