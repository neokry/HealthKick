//
//  AdminFeaturedRecipes.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/23/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct AdminFeaturedRecipesView: View {
    @ObservedObject var adminFeatured = AdminFeaturedRecipes()

    var body: some View {
        List {
            ForEach(FeaturedRecipeSections.allCases, id: \.self) { section in
                NavigationLink(destination: AdminSectionEditor(adminFeatured: self.adminFeatured, sectionID: section.rawValue)) {
                    Text("\(section.rawValue)")
                }
            }
        }.navigationBarTitle("Featured")
    }
}

struct AdminSectionEditor: View {
    @EnvironmentObject var user: AppUser
    @ObservedObject var adminFeatured: AdminFeaturedRecipes
    @State private var showingSheet = false
    @State private var selected = [UserRecipe]()
    var sectionID: String

    var body: some View {
        List {
            if self.adminFeatured.recipesForSection != nil {
                ForEach(self.adminFeatured.recipesForSection!) { recipe in
                    Text(recipe.name)
                }
            }
        }
        .onAppear(perform: {
            self.adminFeatured.loadForSection(sectionID: self.sectionID)
        })
        .navigationBarTitle("\(sectionID)", displayMode: .inline)
        .navigationBarItems(trailing: Button("Add") {
            self.showingSheet = true
        })
    }
}
