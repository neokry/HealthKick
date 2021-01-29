//
//  RecipeNutrients.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/27/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct RecipeNutrients: View {
    @EnvironmentObject var user: AppUser
    var recipe: RecipeDetail

    var body: some View {
        HStack {
            VStack {
                NutrientPieChart(setTo: Double(self.recipe.friendlyCalories), maxValue: self.user.userProfile!.DailyCalorieGoal, innerText: "Calories")
                Text("\(self.recipe.friendlyCalories, specifier: "%.0f")")
                    .font(.footnote)
            }

            VStack {
                NutrientPieChart(setTo: Double(self.recipe.friendlyFat), maxValue: self.user.userProfile!.fatGoal, innerText: "Fat")
                Text("\(self.recipe.friendlyFat, specifier: "%.0f")g")
                    .font(.footnote)
            }

            VStack {
                NutrientPieChart(setTo: Double(self.recipe.friendlyCarb), maxValue: self.user.userProfile!.carbGoal, innerText: "Carbs")
                Text("\(self.recipe.friendlyCarb, specifier: "%.0f")g")
                    .font(.footnote)
            }

            VStack {
                NutrientPieChart(setTo: Double(self.recipe.friendlyProtien), maxValue: self.user.userProfile!.protienGoal, innerText: "Protien")
                Text("\(self.recipe.friendlyProtien, specifier: "%.0f")g")
                    .font(.footnote)
            }
        }
        .padding(5)
    }
}

struct NutrientPieChart: View {
    @State var currentValue: CGFloat = 0
    var setTo: Double
    var maxValue: Double
    var innerText: String
    let scale: CGFloat = 1.0

    var percentageString: Double {
        return (self.setTo / self.maxValue) * 100
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                .trim(from: 0, to: 1)
                    .stroke(Color.black.opacity(0.09), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: geo.size.width * self.scale, height: geo.size.height * self.scale)

                Circle()
                    .trim(from: 0, to: self.currentValue)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: geo.size.width * self.scale, height: geo.size.height * self.scale)
                    .rotationEffect(.init(degrees: -90))

                VStack {
                    Text(self.innerText)
                        .font(.footnote)
                        .padding(.bottom, 5)

                    Text("\(self.percentageString, specifier: "%.0f")%")
                        .minimumScaleFactor(0.9)
                        .font(.footnote)
                        .padding(.bottom, 5)

                }

            }
        }
        .onAppear(perform: {
            return withAnimation(Animation.easeOut(duration: 1).delay(0.5)) {
                self.currentValue = CGFloat(self.setTo / self.maxValue)
            }
        })
    }
}

struct RecipeNutrientsOld: View {
    var recipe: Recipe

    var body: some View {
        VStack {
            ForEach(self.recipe.friendlyDailyNutrients, id: \.self) { nutrient in
                HStack {
                    Text("\(nutrient.label)")
                        .frame(width: 100, alignment: .trailing)
                    NutrientBar(nutrient: nutrient, yield: self.recipe.yield)
                    Spacer()
                    Text("\(nutrient.quantity / Float(self.recipe.yield), specifier: "%.0f")%")
                }

            }

            VStack {
                Text("Calories per serving: \(recipe.friendlyCalories, specifier: "%.0f")")
                    .font(.subheadline)
                Text("Servings per prep: \(recipe.yield)")
                    .font(.subheadline)
            }
            .padding()
        }
    }
}

struct NutrientBar: View {
    @State var size: CGFloat = 0
    var nutrient: NutrientInfo
    var yield: Float

    var body: some View {
        Rectangle()
            .fill(Color.green)
            .frame(width: size, height: 5.0)
            .onAppear(perform: {

                return withAnimation(Animation.easeOut(duration: 1).delay(0.5)) {
                    var width = CGFloat(self.nutrient.quantity / self.yield)
                    if width > 140 { width = 140 }
                    self.size = width
                }
            })

    }
}
