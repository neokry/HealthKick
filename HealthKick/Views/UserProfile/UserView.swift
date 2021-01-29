//
//  UserView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 5/1/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct UserView: View {
    @Environment(\.imageCache) var cache: ImageCache
    @EnvironmentObject var user: AppUser
    @State var showSheet = false
    @State var showSettings = false
    @State var signOut = false
    @Binding var offset: CGFloat

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    if self.user.streamClient != nil && self.user.streamClient?.streamUser != nil {
                        HStack {
                            if self.user.streamClient!.streamUser!.imgURL != nil {
                                AsyncImage(url: self.user.streamClient!.streamUser!.imgURL!, cache: self.cache, placeholder: Text(" "))
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Text(self.user.streamClient!.streamUser!.fullName ?? " ")

                            Spacer()

                            Button(action: {
                                self.showSettings = true
                                self.showSheet = true
                            }) {
                                Image("gear")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 10)

                        Divider()
                    }

                    ZStack {
                        UserRecipesView()
                            .padding(.bottom, self.user.userRecipes?.count ?? 0 > 0 ? 0 : 20)

                        if self.user.userRecipes?.count ?? 0 > 0 {
                            HStack {
                                Spacer()
                                VStack {
                                    Spacer()
                                    Button(action: {
                                        self.offset = 0
                                    }) {
                                        ZStack {
                                            Color.green.frame(width: 60, height: 60).clipShape(Circle())
                                            Image(systemName: "text.badge.plus")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20)
                                                .foregroundColor(.white)
                                        }

                                    }
                                    .padding(.trailing, 15)
                                    .padding(.bottom, 15)
                                }
                            }
                        } else {
                            Button(action: {
                                self.offset = 0
                            }) {
                                Text("Create your first recipe")
                                    .font(.caption)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 20).stroke(Color.black))
                            }.padding(.top, geo.size.height * 0.17)
                        }
                    }

                }
            }
            .navigationBarTitle(" ")
            .navigationBarHidden(true)
            .sheet(isPresented: self.$showSheet) {
                SettingsView(signOut: self.$signOut).environmentObject(self.user)
                    .onDisappear(perform: {
                        if self.signOut {
                            self.user.signOut()
                        }
                    })
            }
        }
    }
}
