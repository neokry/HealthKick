//
//  RecipeSignIn.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/29/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct RecipeSignIn: View {
    @State private var showSignIn = false
    var recipe: recipe
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        VStack {
            if showSignIn {
                SignInView()
            } else {
                RecipeDetail(showSignIn: $showSignIn, recipe: recipe, width: width, height: height)
            }
        }
        .animation(.spring())
    }
}
