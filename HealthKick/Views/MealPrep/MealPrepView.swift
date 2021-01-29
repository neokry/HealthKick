//
//  FeaturedView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/25/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct UserMealPrepView: View {
    @EnvironmentObject var user: AppUser

    var body: some View {
        NavigationView {
            if user.userMealPreps != nil {
                MealPrepView(mealPreps: user.userMealPreps!)
            } else {
                EmptyView()
            }
        }
    }
}

struct MealPrepView: View {
    @EnvironmentObject var user: AppUser
    @ObservedObject var mealPreps: UserMealPreps
    @State private var addRecipes = false
    @State private var showNutrients = false
    @State private var showSheet = false
    @State private var isAdd = false

    var mealPrepDay: MealPrepDay {
        return (self.mealPreps.getMealPrepForDay(dayIndex: self.mealPreps.index)) ?? MealPrepDay(day: Date(), recipes: [UserRecipe]())
    }
    /*
    var recipes: [UserRecipe] {
        
        return (self.user.userRecipes?.recipes) ?? [UserRecipe]()
 
    }
 */

    var body: some View {
        GeometryReader { geo in
            VStack {
                //MealPrepAddRecipes(mealPreps: self.mealPreps, mealPrepDay: self.mealPrepDay, addRecipes: self.$addRecipes, recipes: self.user.userRecipes?.recipes ?? [UserRecipe]())

                MealPrepsHeaderView(mealPreps: self.mealPreps, isAdd: self.$isAdd)

                NavigationLink(destination: MealPrepNutrients(mealPreps: self.mealPreps), isActive: self.$showNutrients) {
                    EmptyView()
                }

                ZStack {
                    PagerView(pageCount: 7, currentIndex: self.$mealPreps.index) {
                        ForEach(0 ..< 7, id: \.self) { _ in
                            MealPrepItemView(mealPrepDay: self.mealPrepDay, isAdd: self.$isAdd)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height * 0.88)

                    HStack {
                        Button(action: { self.showNutrients = true }) {
                            HStack {
                                Text("Nutrients")
                                Image(systemName: "person.crop.circle")
                            }
                                .padding([.leading, .trailing], 25)
                                .padding([.top, .bottom], 10)
                                .foregroundColor(.white)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 10)
                        }
                        .padding(.trailing, 5)

                        Button(action: {
                            self.addRecipes = true
                            self.isAdd = true
                        }) {
                            HStack {
                                Text("Edit Day")
                                Image(systemName: "pencil.circle")
                            }
                                .padding([.leading, .trailing], 25)
                                .padding([.top, .bottom], 10)
                                .foregroundColor(.white)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 10)
                        }
                    }
                    .padding(.top, geo.size.height * 0.75)

                }
            }
            .navigationBarTitle(Text(self.mealPreps.getDayOfWeek() + ", " + self.mealPreps.friendlyDay).font(.subheadline), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: { self.showSheet = true }) {
                Image(systemName: "calendar")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
            })
                .sheet(isPresented: self.$showSheet, onDismiss: { self.mealPreps.loadWeekFromDay(day: self.mealPreps.calendarManager.selectedDate ?? Date()) }) {
                RKViewController(isPresented: self.$showSheet, rkManager: self.mealPreps.calendarManager)
                    .padding(.top, 10)
            }
        }
    }
}

struct MealPrepItemView: View {
    @ObservedObject var mealPrepDay: MealPrepDay
    @Binding var isAdd: Bool

    var body: some View {
        VStack {
            Divider()

            MealPrepDayRecipes(recipes: self.mealPrepDay.recipes, isAdd: self.$isAdd)
                .padding(.top, -7)

        }
    }
}

struct MealPrepAddRecipes: View {
    @ObservedObject var mealPreps: UserMealPreps
    @ObservedObject var mealPrepDay: MealPrepDay
    @Binding var addRecipes: Bool
    var recipes: [ImportedRecipe]

    var body: some View {
        /*
        NavigationLink(destination: RecipeSelector(selected: self.$mealPrepDay.recipes, recipes: self.recipes).onDisappear(perform: {
            self.mealPreps.AddRecipesToDay(day: self.mealPreps.selectedDay, recipes: self.mealPrepDay.recipes)
            }).onDisappear(perform: {
                self.mealPreps.AddRecipesToDay(day: self.mealPrepDay.day, recipes: self.mealPrepDay.recipes)
            }), isActive: self.$addRecipes){
            EmptyView()
        }
 */
        EmptyView()
    }
}

struct MealPrepsHeaderView: View {
    @ObservedObject var mealPreps: UserMealPreps
    @Binding var isAdd: Bool

    var body: some View {
        HStack {
            ForEach(0 ..< 7) { idx in
                Button(action: {
                    self.mealPreps.index = idx
                    self.isAdd = false
                }) {
                    mealPrepHeaderItem(mealPreps: self.mealPreps, idx: idx)
                }
            }
        }
    }
}

struct mealPrepHeaderItem: View {
    @ObservedObject var mealPreps: UserMealPreps
    var idx: Int

    var body: some View {
        ZStack {
            VStack {
                Circle()
                    .stroke(lineWidth: 3)
                    .frame(width: 35)
                    .padding([.leading, .trailing], 5)
                    .foregroundColor( idx == self.mealPreps.index ? Color.init(red: 0/255, green: 128/255, blue: 0/255) : .gray)
                    .shadow(radius: 10)
            }

            Text(self.mealPreps.daysOfWeek[idx])
                .fontWeight(.bold)
                .foregroundColor( idx == self.mealPreps.index ? Color.init(red: 0/255, green: 128/255, blue: 0/255) : .gray)
        }
    }
}
