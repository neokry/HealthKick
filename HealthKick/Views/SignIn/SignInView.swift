//
//  SignUpView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/28/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var user: AppUser
    @Environment(\.presentationMode) var presentationMode
    @Binding var showSignIn: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showingSheet = false
    var geo: GeometryProxy

    var body: some View {
        VStack {

            Text("Sign In")
                .font(.title)
                .fontWeight(.bold)

            Spacer()

            ZStack {
                ProfileControlBackground(geo: geo, sizing: 0.85)
                TextField("Email", text: $username)
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

            Spacer()

            Button(action: {
                self.user.signInWithEmail(email: self.username, password: self.password) { (verified, status) in
                    if !verified {
                        self.alertMessage = status
                        self.showingAlert = true
                    } else {
                        self.user.setLogInStatus(true)
                    }
                }
            }) {
                Text("Login")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .background(Color.init(red: 0/255, green: 128/255, blue: 0/255))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.bottom, 10)
            }

            Button(action: {}) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
                    .font(.subheadline)
            }
            .padding(.bottom, 40)

            GoogleSignInView()
                .frame(width: 120, height: 50)
                .padding(.bottom, 70)

        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(self.alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingSheet) {
            SignUpView()
                .environmentObject(self.user)
        }
    }
}
