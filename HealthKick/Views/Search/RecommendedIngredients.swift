//
//  RecommendedIngredients.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/28/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct RecommendedIngredients: View {
    @EnvironmentObject var user: AppUser
    @Binding var searchText: String
    @Binding var loadSearchResult: Bool

    var body: some View {
        VStack {
            Text("Recommended Ingredients")
                .font(.subheadline)
                .padding(.bottom, 10)

            VStack(alignment: .leading) {
                ForEach(0 ..< 5, id: \.self) { row in
                    HStack {
                        ForEach(0 ..< 3, id: \.self) { col in
                            Button(action: {
                                self.searchText = self.user.recommendedIngredients[row * 3 + col]
                                self.loadSearchResult = true
                            }) {
                                Text(self.user.recommendedIngredients[row * 3 + col])
                                    .font(.caption)
                                    .padding(5)
                                    .padding([.leading, .trailing], 15)
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }
}
