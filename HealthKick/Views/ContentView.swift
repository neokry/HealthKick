//
//  ContentView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/25/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var user: AppUser

    var body: some View {
        Group {
            if user.isLoggedIn {
                UserContent()
            } else {
                ProfileBuilderView()
            }
        }
        .animation(.easeInOut(duration:0.5))
    }
}



struct UserContent: View {
    @State private var selection = 0
    @State private var showSheet = false
    @State private var builderType: BuilderType = .url
    @EnvironmentObject var user: AppUser

    var body: some View {
        Group {
            if user.isLoaded {
                TabView(showSheet: self.$showSheet, builderType: self.$builderType)
                    .onAppear(perform: {
                        self.showSheet = self.user.showTutorial
                    })
            } else {
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.top, 50)
                    .shadow(radius: 20)
                    .padding(.bottom, 20)
            }
        }
        .animation(.easeInOut(duration:0.5))
        .sheet(isPresented: self.$showSheet) {
            if self.user.showTutorial {
                TutorialCarousel() 
                    .environmentObject(self.user)
            } else {
                UserRecipeBuilder(builderType: self.builderType)
            }
        }
    }
}

struct PopOver: View {
    @Binding var showSheet: Bool
    @Binding var offset: CGFloat
    @Binding var builderType: BuilderType

    var body: some View {
        VStack {
            Text("Add Recipe")

            Divider()

            VStack(alignment: .leading, spacing: 18) {
                Button(action: {
                    self.offset = UIScreen.main.bounds.height
                    self.builderType = .url
                    self.showSheet = true
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "link.circle.fill")
                            .renderingMode(.original)
                        Text("Recipe from URL")
                    }
                }

                Divider()

                Button(action: {
                    self.offset = UIScreen.main.bounds.height
                    self.builderType = .freeText
                    self.showSheet = true
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "textformat")
                            .renderingMode(.original)
                        Text("Enter ingredients Manually")
                    }
                }
            }.foregroundColor(.black)
        }
        .frame(width: 250)
        .padding(20)
    }
}

struct TabView: View {

    @State var index = 0
    @State var showPopOver = false
    @State var offset: CGFloat = UIScreen.main.bounds.height
    @Binding var showSheet: Bool
    @Binding var builderType: BuilderType

    var body: some View {

        // tabview with navigation bar...

        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                ZStack {
                    Group {
                        UserStreams()
                            .opacity(self.index == 0 ? 1 : 0)

                        SearchViewNew()
                            .opacity(self.index == 1 ? 1 : 0)

                        UserView(offset: self.$offset)
                            .opacity(self.index == 2 ? 1 : 0)

                        UserGroceryListView()
                            .opacity(self.index == 3 ? 1 : 0)

                        //UserMealPrepView()
                            //.opacity(self.index == 4 ? 1 : 0)
                    }
                    .animation(nil)

                    if self.offset <= 100 {
                        Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                self.offset = UIScreen.main.bounds.height
                            }
                    }

                    VStack {
                        Spacer()
                        PopOver(showSheet: self.$showSheet, offset: self.$offset, builderType: self.$builderType)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.bottom, geo.size.height * 0.04)
                    .offset(y: self.offset)
                }
                .padding(.bottom, geo.size.height * 0.085)
            }

            HStack(spacing: 0) {

                Button(action: {

                    self.index = 0

                }) {

                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23)
                        .foregroundColor(self.index == 0 ? Color.green : Color.primary.opacity(0.25))
                        .padding(.horizontal)
                }
                .padding(.leading, 20)

                Spacer(minLength: 0)

                Button(action: {
                    self.index = 1
                }) {

                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(self.index == 1 ? Color.green : Color.primary.opacity(0.25))
                        .padding(.horizontal)
                }

                Spacer(minLength: 0)

                Button(action: {
                    self.index = 2
                }) {

                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(self.index == 2 ? Color.green : Color.primary.opacity(0.25))
                        .padding(.horizontal)
                }

                //Spacer(minLength: 0)

                /*
                Button(action: {
                    if self.offset <= 100 {
                        self.offset = UIScreen.main.bounds.height
                    }else{
                        self.offset = 0
                    }
                }) {
                    
                    Image(systemName: self.offset <= 100 ? "xmark.circle.fill" : "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28)
                        .foregroundColor(Color.primary)
                        .padding(.horizontal)
                }
 */

                Spacer(minLength: 0)

                Button(action: {

                    self.index = 3

                }) {

                    Image(systemName: "list.bullet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(self.index == 3 ? Color.green : Color.primary.opacity(0.25))
                        .padding(.horizontal)
                }
                .padding(.trailing, 20)
                /*
                Button(action: {
                    
                    self.index = 4
                    
                }) {
                    
                    Image(systemName: "calendar.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23)
                        .foregroundColor(self.index == 4 ? Color.green : Color.primary.opacity(0.25))
                        .padding(.horizontal)
                }
                .padding(.leading, 20)
                */
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
            .clipShape(CShape())
            .background(Color.white)
            .shadow(color: Color.primary.opacity(0.08), radius: 5, x: 0, y: -5)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
struct CShape: Shape {

    func path(in rect: CGRect) -> Path {

        // center curve...

        return Path {path in

            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))

            // center curve..

            path.addArc(center: CGPoint(x: rect.width / 2, y: 0), radius: 35, startAngle: .zero, endAngle: .init(degrees: -180), clockwise: true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
