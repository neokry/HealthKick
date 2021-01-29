//
//  SearchView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/25/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics
import Introspect

struct ExploreView: View {
    @State private var showSearch = false
    @State private var searchText = ""
    @State private var loadSearchResults = false

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    if self.showSearch && !self.loadSearchResults {
                        TypeAheadSearch(showSearch: self.$showSearch, searchText: self.$searchText, loadSearchResults: self.$loadSearchResults)
                    } else if self.loadSearchResults {
                        SearchView()
                            .navigationBarTitle(" ")
                            .navigationBarHidden(true)
                    } else {
                        SearchButton(showSearch: self.$showSearch)
                        RecommendedRecipes(geo: geo)
                    }
                }
            }
            .navigationBarTitle(" ")
            .navigationBarHidden(true)
        }
    }
}

struct SearchButton: View {
    @Binding var showSearch: Bool

    var body: some View {
        HStack {
            Group {
                Button(action: {
                    self.showSearch = true
                }) {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                    Spacer()
                }
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.gray.clipShape(RoundedRectangle(cornerRadius: 10)).opacity(0.2))
            .padding(.horizontal, 10)
        }

    }
}

struct TypeAheadSearch: View {
    @Binding var showSearch: Bool
    @Binding var searchText: String
    @Binding var loadSearchResults: Bool

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: self.$searchText, onEditingChanged: {(changed) in self.loadSearchResults = !changed})
                    .introspectTextField { textField in
                        textField.becomeFirstResponder()
                    }
                    .keyboardType(.webSearch)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.gray.clipShape(RoundedRectangle(cornerRadius: 10)).opacity(0.2))
                    .padding(.horizontal, 10)

                Button("Cancel") {
                    self.showSearch = false
                }
                .padding(.trailing, 10)
            }

            Spacer()

        }
    }
}
