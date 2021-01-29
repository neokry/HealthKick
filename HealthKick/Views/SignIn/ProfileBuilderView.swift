//
//  ProfileBuilder.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/25/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct ProfileBuilderView: View {
    @ObservedObject var userProfile = UserProfile()
    @State private var showSignIn = false
    @State private var index = 0
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    @State private var sheetType: SheetType = .height

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    VStack {
                        ProfileBuilderHeaderView(geo: geo, showSignIn: self.$showSignIn, index: self.$index)

                        if self.showSignIn {
                            SignInView(showSignIn: self.$showSignIn, geo: geo)
                        } else {
                            if self.index == 0 {
                                WeightGoalsView(userProfile: self.userProfile, showSignIn: self.$showSignIn, index: self.$index, geo: geo)
                            } else if self.index == 1 {
                                ProfileInfoView(userProfile: self.userProfile, geo: geo, offset: self.$offset, sheetType: self.$sheetType, index: self.$index)
                            } else if self.index == 2 {
                                ProfileBuilderDietAllergy(userProfile: self.userProfile, filter: self.userProfile.filter, geo: geo, index: self.$index)
                            } else if self.index == 3 {
                                ProfileBuilderSignUp(index: self.$index, geo: geo)
                            }

                        }
                    }

                    if self.index > 0 || self.showSignIn {
                        Button(action: {
                            if self.showSignIn {
                                self.showSignIn = false
                            } else {
                                self.index -= 1
                            }
                        }) {
                            Text("Back")
                                .foregroundColor(Color.green)
                        }
                        .padding(.bottom, geo.size.height * 0.95)
                        .padding(.trailing, geo.size.width * 0.8)
                    }

                    VStack {
                        Spacer()
                        BodyProfileActionSheet(profile: self.userProfile, offset: self.$offset, type: self.$sheetType)
                    }
                    .background((self.offset <= 100 ? Color(UIColor.label).opacity(0.3) : Color.clear).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        self.offset = 0
                    })
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .animation(.default)
            .navigationBarHidden(true)
            .navigationBarTitle("")
        }
    }
}

struct ProfileBuilderHeaderView: View {
    var geo: GeometryProxy
    @Binding var showSignIn: Bool
    @Binding var index: Int

    var body: some View {
        VStack {
            Image("icon")
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * 0.3)
                .padding()

            if !showSignIn {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 30, height: 30)

                        Text("1")
                            .padding()
                            .foregroundColor(.white)
                    }

                    ZStack {
                        Circle()
                            .fill(self.index > 0 ? Color.green : Color.green.opacity(0.5))
                            .frame(width: 30, height: 30)

                        Text("2")
                            .padding()
                            .foregroundColor(.white)
                    }

                    ZStack {
                        Circle()
                            .fill(self.index > 1 ? Color.green : Color.green.opacity(0.5))
                            .frame(width: 30, height: 30)

                        Text("3")
                            .padding()
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct ProfileBuilderSignUp: View {
    @EnvironmentObject var user: AppUser
    @ObservedObject private var keyboard = KeyboardResponder()
    @Binding var index: Int
    var geo: GeometryProxy
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {

            Text("Sign up to get started")
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.85)
                TextField("First Name", text: $firstName)
                    .padding(.horizontal, 35)
                    .cornerRadius(5)
            }
            .padding(.bottom, 10)

            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.85)
                TextField("Last Name", text: $lastName)
                    .padding(.horizontal, 35)
                    .cornerRadius(5)
            }
            .padding(.bottom, 10)

            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.85)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal, 35)
                    .cornerRadius(5)
            }
            .padding(.bottom, 10)

            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.85)
                SecureField("Password", text: $password)
                    .padding(.horizontal, 35)
                    .cornerRadius(5)
            }
            .padding(.bottom, 10)

            Button(action: {
                self.user.signUpWithEmail(email: self.email, password: self.password) { (verified, message) in
                    if !verified {
                        self.errorMessage = message
                        self.showAlert = true
                    } else {
                        self.user.displayName = "\(self.firstName) \(self.lastName)"
                        self.user.setLogInStatus(true)
                    }
                }
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.85, color: Color.green)

                    Text("Sign up with email")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                }
                .padding(.bottom, 20)
            }

            GoogleSignInView()
                .frame(width: 120, height: 50)

            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(self.errorMessage), dismissButton: .default(Text("OK")))
        }
        .padding(.bottom, keyboard.currentHeight > 0 ? keyboard.currentHeight - 40 : 15)
    }
}

struct ProfileBuilderEmailSignUp: View {
    var body: some View {
        Text("Email")
    }
}

struct ProfileBuilderDietAllergy: View {
    @ObservedObject var userProfile: UserProfile
    @ObservedObject var filter: Filter
    var geo: GeometryProxy
    @Binding var index: Int

    var body: some View {
        VStack {
            Text("Any diet restrictions or allergies?")
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            HStack(alignment: .top) {
                DietCheckboxList(selectedDiet: self.$filter.selectedDiet)
                    .padding()
                AllergyCheckboxList(selectedAllergies: self.$filter.selectedAllergies)
                    .padding()
            }
            .foregroundColor(.black)
            .frame(width: geo.size.width * 0.95)
            .padding()
            .detailGroupStyle(width: geo.size.width)

            Spacer()

            Button(action: {
                self.userProfile.SaveSettings()
                self.index += 1
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.85, color: Color.green)

                    Text("Complete")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct ProfileInfoView: View {
    @ObservedObject var userProfile: UserProfile
    var geo: GeometryProxy
    @Binding var offset: CGFloat
    @Binding var sheetType: SheetType
    @Binding var index: Int

    var body: some View {
        VStack {
            Text("Great! let's calculate your calories")
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            Button(action: {
                self.sheetType = SheetType.height
                self.offset = 0
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.85)

                    HStack {
                        Text("Height")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.leading, geo.size.width * 0.15)

                        Spacer()

                        Text("\(userProfile.heightFeet) ft \(userProfile.heightInches) in")
                            .foregroundColor(.gray)
                            .padding(.trailing, geo.size.width * 0.15)
                    }

                }
                .padding(.bottom, 20)
            }

            Button(action: {
                self.sheetType = SheetType.weight
                self.offset = 0
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.85)

                    HStack {
                        Text("Weight")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.leading, geo.size.width * 0.15)

                        Spacer()

                        Text("\(userProfile.weight) lb")
                            .foregroundColor(.gray)
                            .padding(.trailing, geo.size.width * 0.15)
                    }

                }
                .padding(.bottom, 20)
            }

            Button(action: {
                self.sheetType = SheetType.age
                self.offset = 0
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.85)

                    HStack {
                        Text("Age")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.leading, geo.size.width * 0.15)

                        Spacer()

                        Text("\(userProfile.age)")
                            .foregroundColor(.gray)
                            .padding(.trailing, geo.size.width * 0.15)
                    }

                }
                .padding(.bottom, 20)
            }

            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.85)

                HStack {
                    Text("Gender")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.leading, geo.size.width * 0.15)

                    Spacer()

                    Picker("Sex", selection: $userProfile.sex) {
                        Text("Male").tag(SexType.male)
                        Text("Female").tag(SexType.female)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(.gray)
                    .padding(.trailing, geo.size.width * 0.15)
                }

            }
            .padding(.bottom, 20)

            Spacer()

            HStack {
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: 15)

                Text("This information is only saved privately on your device and iCloud")
                    .font(.caption)
            }
            .padding(.horizontal, 20)

            Button(action: {
                self.index += 1
            }) {
                ZStack {
                    ProfileControlBackground(geo: geo, sizing: 0.85, color: Color.green)

                    Text("Continue")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct WeightGoalsView: View {
    @ObservedObject var userProfile: UserProfile
    @Binding var showSignIn: Bool
    @Binding var index: Int
    var geo: GeometryProxy

    var body: some View {
        VStack {
            Text("What goal would you like to start with?")
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            Button(action: {
                self.userProfile.goal = GoalType.lose
                self.index += 1
            }) {
                ProfileTextControl(controlText: "Lose weight", geo: geo)
            }

            Button(action: {
                self.userProfile.goal = GoalType.gain
                self.index += 1
            }) {
                ProfileTextControl(controlText: "Gain Muscle", geo: geo)
            }

            Button(action: {
                self.userProfile.goal = GoalType.maintain
                self.index += 1
            }) {
                ProfileTextControl(controlText: "Stay Current Weight", geo: geo)
            }

            Text("Already have an account?")
                .fontWeight(.bold)
                .padding(.top, geo.size.width * 0.2)
                .padding(.bottom, 5)

            Button(action: {
                self.showSignIn = true
            }) {
                Text("Sign in")
            }

        }
        .padding(.bottom, 20)
    }
}

struct ProfileTextControl: View {
    var controlText: String
    var geo: GeometryProxy

    var body: some View {
        ZStack {
            ProfileControlBackground(geo: geo, sizing: 0.85)

            HStack {
                Text(controlText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.leading, geo.size.width * 0.15)

                Spacer()
            }

        }
        .padding(.bottom, 20)
    }
}

struct ProfileControlBackground: View {
    var geo: GeometryProxy
    var sizing: CGFloat
    var color: Color = Color.white

    var body: some View {
        color
            .frame(width: geo.size.width * sizing, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
    }
}
