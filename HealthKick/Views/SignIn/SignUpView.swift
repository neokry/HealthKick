//
//  SignUpView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/30/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var user: AppUser
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showAlert = false
    var body: some View {

        ZStack {
            Color.green.edgesIgnoringSafeArea(.all)

            VStack {

                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
                    .padding(.top, 50)
                    .shadow(radius: 20)
                    .padding(.bottom, 20)

                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding()

                TextField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding()

                Button(action: {
                    self.user.signUpWithEmail(email: self.email, password: self.password) { (verified, message) in
                        if !verified {
                            self.errorMessage = message
                            self.showAlert = true
                        } else {
                            self.user.setLogInStatus(true)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .background(Color.init(red: 0/255, green: 128/255, blue: 0/255))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.bottom, 10)
                }

                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(self.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
