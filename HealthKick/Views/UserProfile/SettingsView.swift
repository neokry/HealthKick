//
//  SettingsView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/12/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var user: AppUser
    @State private var showSignout = false
    @Binding var signOut: Bool

    var body: some View {
        Group {
            if user.userProfile != nil {
                NavigationView {
                    List {
                        NavigationLink(destination: ProfileOptions(profile: user.userProfile!)) {
                            Text("My Body")
                                .padding()
                        }

                        NavigationLink(destination: StreamEditProfileView()) {
                            Text("My Profile")
                                .padding()
                        }

                        Text("Upgrade to Pro")
                            .padding()

                        Text("Health Kick Attributions")
                            .padding()

                        Text("Feedback and Other Information")
                            .padding()

                        if user.isUserAdmin {
                            NavigationLink(destination: AdminFeaturedRecipesView()) {
                                Text("Admin")
                                    .padding()
                            }
                        }

                        Button(action: {
                            self.showSignout = true
                        }) {
                            Section {
                                ZStack {
                                    Color.red

                                    Text("Sign Out")
                                        .padding()
                                        .foregroundColor(Color.white)
                                }
                            }
                        }
                    }
                    .navigationBarTitle("Settings")
                    .alert(isPresented: $showSignout) {
                        Alert(title: Text("Confirm"), message: Text("Are you sure you want to sign out?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Sign Out"), action: {
                            self.presentationMode.wrappedValue.dismiss()
                            self.signOut = true
                        }))
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

struct DietPrefrences: View {
    @EnvironmentObject var user: AppUser
    @ObservedObject var filter: Filter
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var profile: UserProfile

    var body: some View {
        VStack {
            GeometryReader { geo in
                HStack(alignment: .top) {
                    DietCheckboxList(selectedDiet: self.$filter.selectedDiet)
                        .padding()
                    AllergyCheckboxList(selectedAllergies: self.$filter.selectedAllergies)
                        .padding()
                }
                .frame(width: geo.size.width * 0.95)
                .padding()
                .detailGroupStyle(width: geo.size.width)
                .padding(.leading, 20)

                Spacer()
            }
        }
        .navigationBarItems(trailing: Button("Save") {
            self.profile.SaveSettings()
            self.presentationMode.wrappedValue.dismiss()
            UserRecommendations().GetReccomendations(filter: self.profile.filter, getFeatured: false) { (success, recs) in
                if success {
                    self.user.userRecommendations = recs
                }
            }
            UserRecommendations().GetReccomendations(filter: self.profile.filter, getFeatured: true) { (success, recs) in
                if success {
                    self.user.featuredRecipes = recs
                }
            }
        })
        .navigationBarTitle("My Diet")

    }
}

struct ProfileOptions: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var user: AppUser
    @ObservedObject var profile: UserProfile
    @State var notifications = false
    @State var showBodyProfile = false
    @State var offset: CGFloat = UIScreen.main.bounds.height
    @State var sheetType: SheetType = .height

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Skill Level").font(.subheadline)) {
                    Picker("Skill level", selection: $profile.skill) {
                        Text("Beginner").tag(SkillType.Beginner)
                        Text("Intermediate").tag(SkillType.Intermediate)
                        Text("Advanced").tag(SkillType.Advanced)
                    }.pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Body Profile").font(.subheadline)) {
                    Button(action: {
                        self.sheetType = SheetType.height
                        self.offset = 0
                    }) {
                        HStack {
                            Text("Height")
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(profile.heightFeet) ft \(profile.heightInches) in")
                                .foregroundColor(.gray)
                        }
                    }

                    Button(action: {
                        self.sheetType = SheetType.weight
                        self.offset = 0
                    }) {
                        HStack {
                            Text("Weight")
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(profile.weight) lb")
                                .foregroundColor(.gray)
                        }
                    }

                    Button(action: {
                        self.sheetType = SheetType.age
                        self.offset = 0
                    }) {
                        HStack {
                            Text("Age")
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(profile.age)")
                                .foregroundColor(.gray)
                        }
                    }

                    HStack {
                        Text("Gender")
                        Picker("Sex", selection: $profile.sex) {
                            Text("Male").tag(SexType.male)
                            Text("Female").tag(SexType.female)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.leading, 60)
                    }

                    HStack {
                        Text("Calorie Goal")
                        Spacer()
                        Text("\(profile.DailyCalorieGoal, specifier: "%.0f")")
                    }
                }

                Section(header: Text("Calorie Goals")) {
                    HStack {
                        Picker("Goal", selection: $profile.goal) {
                            Text("Lose Weight").tag(GoalType.lose)
                            Text("Maintain Weight").tag(GoalType.maintain)
                            Text("Gain Weight").tag(GoalType.gain)
                        }
                    }

                    HStack {
                        Picker("Activity Level", selection: $profile.activity) {
                            Text("Sedentary").tag(ActivityType.sedentary)
                            Text("Light").tag(ActivityType.light)
                            Text("Moderate").tag(ActivityType.moderate)
                            Text("Active").tag(ActivityType.active)
                            Text("Very Active").tag(ActivityType.veryActive)
                        }
                    }

                    if profile.goal != GoalType.maintain {
                        HStack {
                            Picker("Goal Intensity", selection: $profile.intensity) {
                                Text("Low").tag(GoalIntensity.low)
                                Text("Medium").tag(GoalIntensity.medium)
                                Text("High").tag(GoalIntensity.high)
                            }
                        }
                    }
                }

                Section(header: Text("Macros")) {
                    Toggle("Use Custom Macros", isOn: $profile.useCustomMacros)
                    if profile.useCustomMacros {
                        Stepper(value: $profile.customFat, in: 0.0 ... 1.0, step: 0.05) {
                            Text("\(Int(self.profile.customFat * 100))% Fats")
                        }
                        Stepper(value: $profile.customCarbs, in: 0.0 ... 1.0, step: 0.05) {
                            Text("\(Int(self.profile.customCarbs * 100))% Carbs")
                        }
                        Stepper(value: $profile.customProtien, in: 0.0 ... 1.0, step: 0.05) {
                            Text("\(Int(self.profile.customProtien * 100))% Protiens")
                        }
                    }
                }

                Section(header: Text("Recieve Notifications").font(.subheadline)) {
                    Toggle("Recieve Notifications", isOn: $notifications)
                }
            }

            VStack {
                Spacer()
                BodyProfileActionSheet(profile: profile, offset: self.$offset, type: self.$sheetType)
            }
            .background((self.offset <= 100 ? Color(UIColor.label).opacity(0.3) : Color.clear).edgesIgnoringSafeArea(.all)
            .onTapGesture {
                self.offset = 0
            })
            .edgesIgnoringSafeArea(.bottom)

        }
        .animation(.default)
        .navigationBarTitle("My Body", displayMode: .inline)
        .navigationBarItems(trailing: Button("Save") {
            self.profile.SaveSettings()
            self.presentationMode.wrappedValue.dismiss()
        })
    }
}

enum SheetType {
    case height, weight, age
}

struct BodyProfileActionSheet: View {
    @ObservedObject var profile: UserProfile
    @Binding var offset: CGFloat
    @Binding var type: SheetType

    var title: String {
        switch type {
        case .age:
            return "Age"
        case .height:
            return "Height"
        case .weight:
            return "Weight"
        }
    }

    var body : some View {
        NavigationView {
            VStack(spacing: 15) {
                if type == .height {
                    HeightPicker(profile: profile)
                } else if type == .weight {
                    Picker("Weight", selection: self.$profile.weight) {
                        ForEach(20 ..< 500, id: \.self) { idx in
                            Text("\(idx) pounds")
                        }
                    }
                    .labelsHidden()
                } else if type == .age {
                    Picker("Age", selection: self.$profile.age) {
                        ForEach(1 ..< 120, id: \.self) { idx in
                            Text("\(idx)")
                        }
                    }
                    .labelsHidden()
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarItems(leading: Button("Cancel") {
                self.offset = UIScreen.main.bounds.height
            }, trailing: Button("Done") {
                self.offset = UIScreen.main.bounds.height
            })
            .navigationBarTitle(Text(title), displayMode: .inline)
        }
        .frame(height: 275)
        .offset(y: self.offset)
    }
}

struct HeightPicker: View {
    @ObservedObject var profile: UserProfile

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Picker(selection: self.$profile.heightFeet, label: Text("Feet")) {
                    ForEach(3 ..< 8, id: \.self) { idx in
                        Text("\(idx) ft")
                    }
                }
                .frame(maxWidth: geometry.size.width / 2)
                .clipped()

                Picker(selection: self.$profile.heightInches, label: Text("Inches")) {
                    ForEach(0 ..< 12, id: \.self) { idx in
                        Text("\(idx) in")
                    }
                }
                .frame(maxWidth: geometry.size.width / 2)
                .clipped()
            }
        }
    }
}
