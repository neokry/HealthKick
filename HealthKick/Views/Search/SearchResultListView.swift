//
//  SearchResultListView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/26/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct SearchResultListView: View {
    var body: some View {
        EmptyView()
    }
    /*
    @EnvironmentObject var user: AppUser
    @ObservedObject var resultsFeed: SearchResultList
    @State private var showSheet = false
    
    
    var body: some View {
        GeometryReader { geo in
            List(self.resultsFeed.searchHits){ searchHit in
                Button(action: {
                    searchHit.recipe.isFavorite = self.isRecipeFavorite(recipe: searchHit.recipe)
                    self.showSheet = true
                }){
                    SearchResultItem(searchHit: searchHit, width: geo.size.width * 0.85)
                        .onAppear(perform: {
                            if !self.resultsFeed.endOfList {
                                if self.resultsFeed.shouldLoad(searchHit: searchHit) {
                                    do{
                                        try self.resultsFeed.searchRecipes()
                                    }catch{
                                        print("Error searching recipes \(error)")
                                    }
                                    
                                }
                            }
                        })
                        .frame(width: geo.size.width * 0.9, height: 400)
                }
                .sheet(isPresented: self.$showSheet){
                    RecipeDetail(recipe: searchHit.recipe, width: geo.size.width, height: geo.size.height, userID: self.user.userID!, loadedImage: nil)
                        .environmentObject(self.user)
                }
            }
            .animation(nil)
        }
        .alert(isPresented: $resultsFeed.endOfList) {
            Alert(title: Text("Error"), message: Text("No results found"), dismissButton: .default(Text("OK")))
        }
    }
    
    func isRecipeFavorite(recipe: Recipe) -> Bool {
        if self.user.userRecipes?.recipes.first(where: { $0.recipeURI == recipe.uri}) != nil {
            return true
        }
        
        return false
    }
    
    init(searchText: String, filter: String){
        self.resultsFeed = SearchResultList(searchText, filter)
    }
 */
}
