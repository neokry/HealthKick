//
//  MealPrepNutrients.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/7/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct MealPrepNutrients: View {
    @ObservedObject var mealPreps: UserMealPreps
    @State private var totals: MealPrepNutrientTotals?

    var body: some View {
        GeometryReader { geo in
            if self.totals != nil {
                VStack {
                    MealPrepCaloriesView(width: geo.size.width, calories: self.totals!.calories, totalCalories: self.totals!.totalCalories)
                    DailyTotals(totals: self.totals!, width: geo.size.width)
                }
                .padding(.leading, geo.size.width * 0.05)
            }
        }
        .onAppear(perform: loadTotals)
    }

    func loadTotals() {
        self.totals = self.mealPreps.nutrientsTotals()
    }
}

struct MealPrepCaloriesView: View {
    var width: CGFloat
    var calories: [calorieInfo]
    var totalCalories: Float

    var body: some View {
        VStack {
            Text("Calories By Meal")
                .fontWeight(.bold)
                .frame(width: width * 0.95)
                .font(.title)
                .padding(.bottom, 5)

            ForEach(calories, id: \.self) { calorie in
                HStack {
                    Text("\(calorie.label)")
                        .font(.footnote)
                        .frame(width: 100, alignment: .trailing)
                    NutrientBarToday(quantity: (calorie.calories / self.totalCalories) * 100)
                    Spacer()
                    Text("\(calorie.calories, specifier: "%.0f")")
                }
            }.frame(width: width * 0.85)
        }
        .detailGroupStyle(width: width)
    }
}

struct DailyTotals: View {
    @EnvironmentObject var user: AppUser
    var totals: MealPrepNutrientTotals
    var width: CGFloat

    var body: some View {
        VStack {
            Text("Todays Nutrients")
                .fontWeight(.bold)
                .font(.title)
                .padding(.bottom, 5)

            HStack {
                VStack {
                    NutrientPieChart(setTo: Double(self.totals.totalCalories), maxValue: self.user.userProfile!.DailyCalorieGoal, innerText: "Calories")
                    Text("\(self.totals.totalCalories, specifier: "%.0f")")
                        .font(.footnote)
                }

                VStack {
                    NutrientPieChart(setTo: Double(self.totals.totalFat), maxValue: self.user.userProfile!.fatGoal, innerText: "Fat")
                    Text("\(self.totals.totalFat, specifier: "%.0f")g")
                        .font(.footnote)
                }

                VStack {
                    NutrientPieChart(setTo: Double(self.totals.totalCarbs), maxValue: self.user.userProfile!.carbGoal, innerText: "Carbs")
                    Text("\(self.totals.totalCarbs, specifier: "%.0f")g")
                        .font(.footnote)
                }

                VStack {
                    NutrientPieChart(setTo: Double(self.totals.totalProtein), maxValue: self.user.userProfile!.protienGoal, innerText: "Protien")
                    Text("\(self.totals.totalProtein, specifier: "%.0f")g")
                        .font(.footnote)
                }
            }
        }
        .padding(5)
        .frame(width: width * 0.9, height: 160)
        .detailGroupStyle(width: width)
    }
}

struct NutrientBarToday: View {
    @State var size: CGFloat = 0
    var quantity: Float

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.green)
            .frame(width: size * 1.5, height: 10.0)
            .padding([.top, .bottom], 5)
            .onAppear(perform: {
                return withAnimation(Animation.easeOut(duration: 1).delay(0.5)) {
                    var width = CGFloat(self.quantity)
                    if width > 100 { width = 100 }
                    self.size = width
                }
            })
    }
}
