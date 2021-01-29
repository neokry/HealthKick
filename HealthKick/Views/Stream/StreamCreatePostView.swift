//
//  StreamCreatePostView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/12/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct StreamCreatePostView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var user: AppUser
    @State private var showSheet = false
    @State private var firstShow = true
    @State private var postImg: UIImage?
    @State private var postCaption: String = ""
    @State private var postRecipe: ImportedRecipe?
    @State private var takePhoto: Bool = false
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            Group {
                if !self.isLoading {
                    Form {
                        TextField("Write a caption...", text: self.$postCaption)
                             .lineLimit(4)
                             .multilineTextAlignment(.leading)

                        if self.user.userRecipes != nil {
                            EmptyView()
                            
                            NavigationLink(destination: StreamTagRecipeView(selected: self.$postRecipe, recipes: self.user.userRecipes ?? [ImportedRecipe]())){
                                Text(self.postRecipe?.title ?? "Tag Recipe")
                            }
 
                        }

                        if self.postImg != nil {
                            Image(uiImage: self.postImg!)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .onAppear(perform: {
                        if self.firstShow {
                            self.showSheet = true
                            self.firstShow = false
                        }
                    })
                } else {
                    LoadingView(text: "Posting")
                }
            }
            .sheet(isPresented: self.$showSheet) {
                ImagePicker(image: self.$postImg, takePhoto: self.$takePhoto)
            }
            .navigationBarTitle("New Post", displayMode: .inline)
            .navigationBarItems(trailing: Button("Post") {
                self.isLoading = true
                self.user.streamClient?.AddToFeed(img: self.postImg, caption: self.postCaption, recipeID: self.postRecipe?.id) { success in
                    if success {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            })
        }
    }
}
