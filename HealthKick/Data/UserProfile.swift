//
//  UserSettings.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/23/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseAnalytics
import FirebaseCrashlytics

enum SkillType: Int, CaseIterable, Codable {
    case Beginner
    case Intermediate
    case Advanced
}

enum SexType: Int, CaseIterable, Codable {
    case male
    case female
}

enum ActivityType: Int, CaseIterable, Codable {
    case sedentary
    case light
    case moderate
    case active
    case veryActive
}

enum GoalType: String, CaseIterable, Codable {
    case lose
    case maintain
    case gain
}

enum GoalIntensity: Double, CaseIterable, Codable {
    case none = 0.0
    case low = 1.0
    case medium = 2.0
    case high = 3.0
}

class UserProfile: ObservableObject, Codable {
    @Published var skill: SkillType
    @Published var sex: SexType
    @Published var weight: Int
    @Published var heightFeet: Int
    @Published var heightInches: Int
    @Published var age: Int
    @Published var activity: ActivityType
    @Published var goal: GoalType
    @Published var intensity: GoalIntensity
    @Published var useCustomMacros: Bool
    @Published var customFat: Double
    @Published var customCarbs: Double
    @Published var customProtien: Double
    @ObservedObject var filter: Filter

    enum CodingKeys: CodingKey {
        case skill, sex, weight, heightFeet, heightInches, age, activity, goal, intensity, useCustomMacros, customFat, customCarbs, customProtien, filter
    }

    var totalHeightInches: Int {
        return (heightFeet * 12) + heightInches
    }

    var BMR: Double {
        switch sex {
        case .male:
            return 10 * (Double(weight) * 0.453) + 6.25 * (Double(totalHeightInches) * 2.54) - (5 * Double(age)) + 5
        case .female:
            return 10 * (Double(weight) * 0.453) + 6.25 * ((Double(totalHeightInches) * 2.54 * 0.453) - ((5 * Double(age)) - 161))
        }
    }

    var TDEE: Double {
        switch activity {
        case .sedentary:
            return BMR * 1.2
        case .light:
            return BMR * 1.375
        case .moderate:
            return BMR * 1.55
        case .active:
            return BMR * 1.725
        case .veryActive:
            return BMR * 1.9
        }
    }

    var DailyCalorieGoal: Double {
        switch goal {
        case .lose:
            return TDEE * ((100.0 - (5.0 * intensity.rawValue)) / 100.0)
        case .maintain:
            return TDEE
        case .gain:
            return TDEE * ((100.0 + (5.0 * intensity.rawValue)) / 100.0)
        }
    }

    var fatGoal: Double {
        if useCustomMacros == true {
            return customFat
        }

        switch goal {
        case .lose:
            return (DailyCalorieGoal * 0.25) / 9.0
        case .maintain:
            return (DailyCalorieGoal * 0.25) / 9.0
        case .gain:
            return (DailyCalorieGoal * 0.20) / 9.0
        }
    }

    var carbGoal: Double {
        if useCustomMacros == true {
            return customCarbs
        }

        switch goal {
        case .lose:
            return (DailyCalorieGoal * 0.30) / 4.0
        case .maintain:
            return (DailyCalorieGoal * 0.50) / 4.0
        case .gain:
            return (DailyCalorieGoal * 0.45) / 4.0
        }
    }

    var protienGoal: Double {
        if useCustomMacros == true {
            return customProtien
        }

        switch goal {
        case .lose:
            return (DailyCalorieGoal * 0.45) / 4.0
        case .maintain:
            return (DailyCalorieGoal * 0.25) / 4.0
        case .gain:
            return (DailyCalorieGoal * 0.35) / 4.0
        }
    }

    func SaveSettings() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("UserSettings")
            let data = try JSONEncoder().encode(self)
            try data.write(to: filename, options: [.atomicWrite])
            Analytics.logEvent("saved_settings", parameters: ["goal": self.goal])
            Analytics.setUserProperty(self.goal.rawValue, forName: "Goal")
            if let diet = self.filter.selectedDiet {
                Analytics.setUserProperty(diet.rawValue, forName: "Diet")
            } else {
                Analytics.setUserProperty("None", forName: "Diet")
            }

        } catch {
            print("Error saving settings \(error.localizedDescription)")
            Crashlytics.crashlytics().log("Error saving settings \(error.localizedDescription)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(skill, forKey: .skill)
        try container.encode(sex, forKey: .sex)
        try container.encode(weight, forKey: .weight)
        try container.encode(heightFeet, forKey: .heightFeet)
        try container.encode(heightInches, forKey: .heightInches)
        try container.encode(age, forKey: .age)
        try container.encode(activity, forKey: .activity)
        try container.encode(goal, forKey: .goal)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(filter, forKey: .filter)
        try container.encode(useCustomMacros, forKey: .useCustomMacros)
        try container.encode(customFat, forKey: .customFat)
        try container.encode(customCarbs, forKey: .customCarbs)
        try container.encode(customProtien, forKey: .customProtien)
    }

    init() {
        skill = .Beginner
        sex = .male
        weight = 150
        heightFeet = 5
        heightInches = 8
        age = 25
        activity = .moderate
        goal = .maintain
        intensity = .none
        useCustomMacros = false
        customFat = 0.25
        customCarbs = 0.50
        customProtien = 0.25
        filter = Filter()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        skill = try container.decode(SkillType.self, forKey: .skill)
        sex = try container.decode(SexType.self, forKey: .sex)
        weight = try container.decode(Int.self, forKey: .weight)
        heightFeet = try container.decode(Int.self, forKey: .heightFeet)
        heightInches = try container.decode(Int.self, forKey: .heightInches)
        age = try container.decode(Int.self, forKey: .age)
        activity = try container.decode(ActivityType.self, forKey: .activity)
        goal = try container.decode(GoalType.self, forKey: .goal)
        intensity = try container.decode(GoalIntensity.self, forKey: .intensity)
        filter = try container.decode(Filter.self, forKey: .filter)
        useCustomMacros = try container.decode(Bool.self, forKey: .useCustomMacros)
        customFat = try container.decode(Double.self, forKey: .customFat)
        customCarbs = try container.decode(Double.self, forKey: .customCarbs)
        customProtien = try container.decode(Double.self, forKey: .customProtien)
    }
}
