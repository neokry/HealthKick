//
//  RecipeWebsiteView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/28/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct RecipeWebsiteView: View {
    @Environment(\.presentationMode) var presentationMode
    var url: String
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        ZStack {
            WebView(urlString: url)
                .edgesIgnoringSafeArea(.all)

            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .padding(15)
                    .foregroundColor(.green)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(.bottom, height * 0.98)
            .padding(.trailing, width * 0.80)
        }
    }
}
