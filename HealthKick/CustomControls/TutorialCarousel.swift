//
//  Carousel.swift
//  HealthKick
//
//  Created by Patrick Genevich on 7/4/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct TutorialCarousel: View {
    @EnvironmentObject var user: AppUser
    @Environment(\.presentationMode) var presentationMode
    @State var x: CGFloat = 0
    @State var count: CGFloat = 0
    @State var screen = UIScreen.main.bounds.width - 30
    @State var op: CGFloat = 0
    @State var isHidden = true

    @State var data = [
        Card(id: 0, title: "Your personal feed", body: "See what your friends have been eating lately and get inspired. Here you can interact with your friends, make a new post, and see your notifications", img: "house.fill", color: "ColorLightBlue", show: false),
        Card(id: 1, title: "My profile & recipes", body: "Your profile information and saved recipes will show up here. Click on any recipe to get in depth nutrition information, directions, and more", img: "person.crop.circle.fill", color: "ColorPurple", show: false),
        Card(id: 2, title: "Create a recipe", body: "Add recipes from your favorite websites, or make your own. Our recipe builder is simple, easy to use, and has to most accurate nutrition information.", img: "plus.circle.fill", color: "ColorBrown", show: false),
        Card(id: 3, title: "Grocery list", body: "Quickly create a grocery list by selecting the recipe you want to make from the list and we do the rest for you.", img: "list.bullet", color: "ColorPastelBlue", show: false),
        Card(id: 4, title: "Daily Planner", body: "Plan out what you want to eat for the day and get a better overall view of how your recipes are contributing to your diet goals for the day.", img: "calendar.circle.fill", color: "ColorPastelGreen", show: false)
    ]

    var body : some View {

        NavigationView {

            VStack {

                Spacer()

                HStack(spacing: 15) {

                    ForEach(data) {i in

                        CardView(presentationMode: self.presentationMode, data: i)
                            .offset(x: self.x)
                            .highPriorityGesture(DragGesture()

                                .onChanged({ (value) in

                                    if value.translation.width > 0 {

                                        self.x = value.location.x
                                    } else {

                                        self.x = value.location.x - self.screen
                                    }

                                })
                                .onEnded({ (value) in

                                    if value.translation.width > 0 {

                                        if value.translation.width > ((self.screen - 80) / 2) && Int(self.count) != 0 {

                                            self.count -= 1
                                            self.updateHeight(value: Int(self.count))
                                            self.x = -((self.screen + 15) * self.count)
                                        } else {

                                            self.x = -((self.screen + 15) * self.count)
                                        }
                                    } else {

                                        if -value.translation.width > ((self.screen - 80) / 2) && Int(self.count) !=  (self.data.count - 1) {

                                            self.count += 1
                                            self.updateHeight(value: Int(self.count))
                                            self.x = -((self.screen + 15) * self.count)
                                        } else {

                                            self.x = -((self.screen + 15) * self.count)
                                        }
                                    }
                                })
                        )
                    }
                }
                .isHidden(self.isHidden)
                .frame(width: UIScreen.main.bounds.width)
                .offset(x: self.op)

                Spacer()
            }
            .navigationBarTitle(" ")
            .navigationBarHidden(true)
            .animation(.spring())
            .onAppear {

                self.op = ((self.screen + 15) * CGFloat(self.data.count / 2)) - (self.data.count % 2 == 0 ? ((self.screen + 15) / 2) : 0)

                self.data[0].show = true
                self.isHidden = false
            }
        }
    }

    func updateHeight(value: Int) {

        for i in 0..<data.count {

            data[i].show = false
        }

        data[value].show = true
    }
}

struct CardView: View {
    @Binding var presentationMode: PresentationMode
    var data: Card

    var body : some View {
        VStack {
            HStack {
                Text("\(data.id + 1)/5")
                    .fontWeight(.light)
                    .animation(nil)
                    .font(.headline)
                    .padding([.top, .leading], 20)

                Spacer()

                Button(action: {
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "finishedTutorial")
                    self.presentationMode.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .padding([.top, .trailing], 20)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(data.title)
                    .fontWeight(.bold)
                    .font(.title)
                    .padding(.vertical, 13)
                    .padding(.leading)
                    .animation(nil)

                Text(data.body)
                    .fontWeight(.light)
                    .font(.body)
                    .padding(.vertical, 13)
                    .padding(.leading)
                    .animation(nil)

                Spacer()

                HStack {
                    Spacer()

                    Image(systemName: data.img)
                        .resizable()
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: 100)

                    Spacer()
                }

                Spacer()

                if data.id == 0 {
                    HStack {
                        Spacer()
                        Text("(Swipe left to continue)")
                        Spacer()
                    }
                }

                if data.id == 4 {
                    HStack {
                        Spacer()
                        Button(action: {
                            let defaults = UserDefaults.standard
                            defaults.set(true, forKey: "finishedTutorial")
                            self.presentationMode.dismiss()
                        }) {
                            Text("Lets get started")
                                .foregroundColor(Color(data.color))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 20)))
                        }
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 30)

        }
        .frame(width: UIScreen.main.bounds.width - 30, height: data.show ? 530 : 450)
        .foregroundColor(.white)
        .background(Color(data.color))
        .cornerRadius(25)
    }
}

struct Card: Identifiable {

    var id: Int
    var title: String
    var body: String
    var img: String
    var color: String
    var show: Bool
}
