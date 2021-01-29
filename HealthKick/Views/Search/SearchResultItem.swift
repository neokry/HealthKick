//
//  SearchResultItem.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/26/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct SearchResultItem: View {
    var searchHit: searchHit
    var width: CGFloat?
    @Environment(\.imageCache) var cache: ImageCache

    var body: some View {
        VStack {
            HStack {
                if self.searchHit.recipe.imageURL != nil {
                    AsyncImage(url: self.searchHit.recipe.imageURL!, cache: self.cache, placeholder: Text(" "))
                        .scaledToFill()
                        .frame(width: width! * 0.95)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)

                }
            }
            .animation(.easeIn(duration: 0.5))

            Text(self.searchHit.recipe.label)
                .font(.title)
                .fontWeight(.bold)

            Text("Calories per serving: \(searchHit.recipe.friendlyCalories, specifier: "%.0f")")
                .font(.subheadline)
        }
        .padding()
    }
}
