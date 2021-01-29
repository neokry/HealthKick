//
//  RecommendedRecipes.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/28/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct RecommendedRecipes: View {
    @EnvironmentObject var user: AppUser
    @Environment(\.imageCache) var cache: ImageCache
    @State private var selectedRecipeURI: String?
    @State private var selectedRecipeImage: Image?
    @State private var showRecipe = false
    var geo: GeometryProxy

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                if self.user.userRecommendations != nil {
                    ZStack {
                        TrendingSection(selectedRecipeURI: self.$selectedRecipeURI, selectedRecipeImage: self.$selectedRecipeImage, showRecipe: self.$showRecipe, trendingRecs: self.user.userRecommendations!)

                        Text("Trending Recipes")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.bottom, geo.size.height * 0.3)
                            .padding(.trailing, geo.size.width * 0.5)
                    }
                    .padding(.top, 25)
                }

                if self.user.featuredRecipes != nil {

                    ZStack {
                        FeaturedSection(selectedRecipeURI: self.$selectedRecipeURI, selectedRecipeImage: self.$selectedRecipeImage, showRecipe: self.$showRecipe, sectionID: FeaturedRecipeSections.salad.rawValue, featuredRecs: self.user.featuredRecipes!)

                        Text("Our Favorite Salads")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: geo.size.width * 0.5)
                            .padding(.bottom, geo.size.height * 0.3)
                            .padding(.trailing, geo.size.width * 0.5)
                    }

                    ZStack {
                        FeaturedSection(selectedRecipeURI: self.$selectedRecipeURI, selectedRecipeImage: self.$selectedRecipeImage, showRecipe: self.$showRecipe, sectionID: FeaturedRecipeSections.pasta.rawValue, featuredRecs: self.user.featuredRecipes!)

                        Text("Incredible Pastas")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: geo.size.width * 0.5)
                            .padding(.bottom, geo.size.height * 0.3)
                            .padding(.trailing, geo.size.width * 0.5)
                    }

                }
            }

        }
        .sheet(isPresented: self.$showRecipe) {
            EmptyView()
            //RecipeDetailLoader(uri: self.selectedRecipeURI!, isFavorite: false, loadedImage: self.selectedRecipeImage)
                //.environmentObject(self.user)
        }
    }
}

struct RecommendedSection<Content: View>: View {
    let viewBuilder: () -> Content
    var text: String
    var geo: GeometryProxy

    var body: some View {
        ZStack {
            viewBuilder()

            Text(text)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.bottom, geo.size.height * 0.3)
                .padding(.trailing, geo.size.width * 0.5)
        }
    }
}

struct TrendingSection: View {
    @Binding var selectedRecipeURI: String?
    @Binding var selectedRecipeImage: Image?
    @Binding var showRecipe: Bool
    var trendingRecs: [Recommendation]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(trendingRecs) { rec in
                    Button(action: {
                        Analytics.logEvent("recommendation_click", parameters: [
                            "name": rec.name
                         ])
                        self.selectedRecipeURI = rec.uri
                        self.selectedRecipeImage = rec.loadedImage
                        self.showRecipe = true
                    }) {
                        RecommendedListItem(rec: rec)
                    }
                }
            }.frame(height: 200)
        }
    }
}

struct FeaturedSection: View {
    @Binding var selectedRecipeURI: String?
    @Binding var selectedRecipeImage: Image?
    @Binding var showRecipe: Bool
    var sectionID: String
    var featuredRecs: [Recommendation]
    var filteredRecs: [Recommendation]? {
        return featuredRecs.filter({ $0.featuredSection! == sectionID })
    }

    var body: some View {
        Group {
            if filteredRecs != nil && filteredRecs?.count ?? 0 > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(self.filteredRecs!) { rec in
                            Button(action: {
                                Analytics.logEvent("recommendation_click", parameters: [
                                    "name": rec.name
                                 ])
                                self.selectedRecipeURI = rec.uri
                                self.selectedRecipeImage = rec.loadedImage
                                self.showRecipe = true
                            }) {
                                RecommendedListItem(rec: rec)
                            }
                        }
                    }.frame(height: 200)
                }
            }
        }
    }
}

struct RecommendedListItem: View {
    @ObservedObject var rec: Recommendation

    var body: some View {
        Group {
            if rec.loadedImage != nil {
                VStack(alignment: .leading) {
                	rec.loadedImage!
                	    .renderingMode(.original)
                	    .resizable()
                	    .scaledToFill()
                	    .frame(height: 130)
                	    .clipShape(RoundedRectangle(cornerRadius: 20))
                	    .shadow(radius: 10)
                	    .padding(2)

                	Text(rec.name)
                	    .font(.caption)
                        .padding(.top, 2)
                        .padding(.leading, 10)
                        .truncationMode(.tail)
                }
                .frame(width: 250)
            } else {
                Text("Loading...")
            }
        }
        .animation(.default)
        .foregroundColor(.black)
        .padding(.horizontal, 5)
        .padding(.vertical, 20)
    }
}
