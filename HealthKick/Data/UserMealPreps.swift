//
//  MealPrep.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/2/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCrashlytics

enum nutrientStatsRange {
    case today
    case week
    case month
    case year
}

class UserMealPreps: ObservableObject {
    @Published var selectedMealPrepWeek = [MealPrepDay]()
    @Published var index = 0
    var userID: String
    var datesOfWeek = [Date]()
    var daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    var selectedDay: Date {
        self.datesOfWeek[self.index]
    }

    var friendlyDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: selectedDay)
    }

    let db = Firestore.firestore()

    var calendarManager = RKManager(calendar: Calendar.current, minimumDate: minDate, maximumDate: maxDate, mode: 0)

    static var minDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: "2020-01-01")
        return date ?? Date()
    }

    static var maxDate: Date {
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    }

    func nutrientsTotals() -> MealPrepNutrientTotals? {
        if let recipes = getMealPrepForDay(dayIndex: index)?.recipes {
            var totals = MealPrepNutrientTotals(calories: [calorieInfo]())

            for r in recipes {
                totals.calories.append(calorieInfo(label: r.recipeName, calories: (r.calories / Float(r.yeild))))
                totals.totalCalories += (r.calories / Float(r.yeild))
                if let fat = r.totalNutrients.first(where: {$0.label == "Fat"})?.quantity {
                    totals.totalFat += (fat / Float(r.yeild))
                }
                if let carbs = r.totalNutrients.first(where: {$0.label == "Carbs"})?.quantity {
                    totals.totalCarbs += (carbs / Float(r.yeild))
                }
                if let protein = r.totalNutrients.first(where: {$0.label == "Protein"})?.quantity {
                    totals.totalProtein += (protein / Float(r.yeild))
                }
            }

             return totals
        }

        return nil

    }

    func initNutrientsArray() -> [NutrientInfo] {
        var n = [NutrientInfo]()
        n.append(NutrientInfo(label: "Fat", quantity: 0))
        n.append(NutrientInfo(label: "Carbs", quantity: 0))
        n.append(NutrientInfo(label: "Fiber", quantity: 0))
        n.append(NutrientInfo(label: "Protein", quantity: 0))
        n.append(NutrientInfo(label: "Cholesterol", quantity: 0))
        n.append(NutrientInfo(label: "Sodium", quantity: 0))
        return n
    }

    func AddRecipesToDay(day: Date, recipes: [UserRecipe]) {
        do {
            let formatter = DateFormatter()
            formatter.dateStyle = .short

            var mealPrepDay: MealPrepDay
            if let prepDay = selectedMealPrepWeek.first(where: { $0.day == day }) {
                mealPrepDay = prepDay
                mealPrepDay.recipes = recipes
            } else {
                 mealPrepDay = MealPrepDay(day: day, recipes: recipes)
            }

            let userMealPreps = db.collection("userMealPreps").document(userID)
            let newMealPrepDay = userMealPreps.collection("mealPrepDays").document(mealPrepDay.mealPrepDayID.uuidString)

            try newMealPrepDay.setData(from: mealPrepDay) { err in
                if let err = err {
                    print("Error adding meal prep day to database \(err.localizedDescription)")
                }

                Analytics.logEvent("saved_mealprep", parameters: [
                    "day": mealPrepDay.day
                 ])

            }
        } catch {
            print("Error adding meal prep day to database \(error.localizedDescription)")
            Crashlytics.crashlytics().log("Error adding meal prep day to database \(error.localizedDescription)")
        }
    }

    func getMealPrepsForWeek(day: Date, completion: @escaping ([MealPrepDay]) -> Void) {
        let week = getWeekFromDay(day: day)
        var component = DateComponents()
        component.day = 1
        let endOfWeek = Calendar.current.date(byAdding: component, to: week[6])
        let userMealPreps = db.collection("userMealPreps").document(userID)
        let query = userMealPreps.collection("mealPrepDays").whereField("day", isGreaterThan: week[0]).whereField("day", isLessThan: endOfWeek!)

        query.getDocuments {(snap, err) in
            if let err = err {
                print("Error getting weeks meals \(err)")
            } else {
                var preps = [MealPrepDay]()

                let temp = (snap?.documents.compactMap {
                    try? $0.data(as: MealPrepDay.self)
                })!

                for idx in 0 ..< 7 {
                    if let day = temp.first(where: {
                        let order = Calendar.current.compare($0.day, to: week[idx], toGranularity: .day)
                        return order == .orderedSame
                    }) {
                        preps.append(day)
                    } else {
                        let day = MealPrepDay(day: week[idx], recipes: [UserRecipe]())
                        preps.append(day)
                    }
                }

                completion(preps)
            }
        }
    }

    func getWeekFromDay(day: Date) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: day)
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }  // use `flatMap` in Xcode versions before 9.3
        return days
    }

    func getMealPrepForDay(dayIndex: Int) -> MealPrepDay? {
         let day = self.datesOfWeek[dayIndex]

        if let preps = selectedMealPrepWeek.first(where: {
            let order = Calendar.current.compare($0.day, to: day, toGranularity: .day)
            return order == .orderedSame
        }) {
            return preps
        }

        return nil
    }

    func getDayOfWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self.selectedDay)
    }

    func loadWeekFromDay(day: Date) {

        let week = self.getWeekFromDay(day: day)
        self.datesOfWeek = week
        let mutating = self

        self.getMealPrepsForWeek(day: day) { preps in

            mutating.selectedMealPrepWeek = preps

            self.index = self.datesOfWeek.firstIndex(where: {
                let order = Calendar.current.compare($0, to: day, toGranularity: .day)
                return order == .orderedSame
            })!
        }
    }

    init(userID: String) {
        self.userID = userID
        loadWeekFromDay(day: Date())
    }
}

class MealPrepDay: Codable, ObservableObject {
    var mealPrepDayID = UUID()
    var day: Date
    @Published var recipes: [UserRecipe]

    enum CodingKeys: CodingKey {
        case mealPrepDayID, day, recipes
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(mealPrepDayID, forKey: .mealPrepDayID)
        try container.encode(day, forKey: .day)
        try container.encode(recipes, forKey: .recipes)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        mealPrepDayID = try container.decode(UUID.self, forKey: .mealPrepDayID)
        day = try container.decode(Date.self, forKey: .day)
        recipes = try container.decode([UserRecipe].self, forKey: .recipes)
    }

    init(day: Date, recipes: [UserRecipe]) {
        self.day = day
        self.recipes = recipes
    }
}

struct MealPrepNutrientTotals {
    var totalFat: Float = 0.0
    var totalCarbs: Float = 0.0
    var totalProtein: Float = 0.0
    var totalCalories: Float = 0.0
    var calories: [calorieInfo]
}

struct calorieInfo: Hashable {
    var label: String
    var calories: Float
}
