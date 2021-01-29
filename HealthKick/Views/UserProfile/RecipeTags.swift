//
//  RecipeTags.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/27/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct RecipeTags: View {
    var recipe: RecipeDetail

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                ForEach(recipe.dietLabels, id: \.self) { dietLabel in
                    Text(dietLabel)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(2)
                }

                ForEach(recipe.cautions, id: \.self) { caution in
                    Text(caution)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(2)
                }

                ForEach(recipe.healthLabels, id: \.self) { dietLabel in
                    Text(dietLabel)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(2)
                }
            }
        }
        .frame(height: 150)
    }
}
