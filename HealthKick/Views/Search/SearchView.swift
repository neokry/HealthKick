//
//  SearchView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/28/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var user: AppUser
    @State private var searchText = ""
    @State private var loadSearchResults = false

    var shouldLoad: Bool {
        return loadSearchResults == true && searchText.count > 0
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search for Recipies", text: self.$searchText, onEditingChanged: {(changed) in self.loadSearchResults = !changed})
                        .keyboardType(.webSearch)
                }
                .padding(10)
                .background(Color.gray.clipShape(RoundedRectangle(cornerRadius: 10)).opacity(0.2))
                .padding(10)

                VStack {
                    if self.shouldLoad {
                        EmptyView()
                        //SearchResultListView(searchText: self.searchText, filter: self.user.userProfile!.filter.filterString)
                    } else {
                        RecommendedIngredients(searchText: self.$searchText, loadSearchResult: self.$loadSearchResults)
                            .frame(width: geo.size.width * 0.95, height: 200)
                            .detailGroupStyle(width: geo.size.width * 0.95)
                    }
                }

                Spacer()
            }
        }
    }
}
