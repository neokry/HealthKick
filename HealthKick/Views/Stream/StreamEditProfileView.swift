//
//  EditUserView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/11/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct StreamEditProfileView: View {
    @EnvironmentObject var user: AppUser
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var bio: String = ""
    @State private var imgURL: URL?
    @State private var showImagePicker = false
    @State private var profileImage: UIImage?
    @State private var takePhoto: Bool = false
    @Environment(\.imageCache) var cache: ImageCache
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Form {
                Section {
                    HStack {
                        Button(action: {
                            self.showImagePicker = true
                        }) {
                            if self.profileImage == nil {
                                if self.imgURL == nil {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                        .frame(width: 65, height: 65)
                                        .padding(.trailing, 5)
                                } else {
                                    if cache[imgURL!] != nil {
                                        Image(uiImage: cache[imgURL!]!)
                                            .renderingMode(.original)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 65, height: 65)
                                            .clipShape(Circle())
                                            .padding(.trailing, 5)
                                    }
                                }
                            } else {
                                Image(uiImage: self.profileImage!)
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 65, height: 65)
                                    .clipShape(Circle())
                                    .padding(.trailing, 5)
                            }
                        }

                        VStack {
                            TextField("First Name", text: self.$firstName)
                            TextField("Last Name", text: self.$lastName)
                        }
                    }
                }

                Section {
                    TextField("City", text: self.$city)
                    TextField("State", text: self.$state)
                    TextField("Bio", text: self.$bio)
                }
            }
        }
        .sheet(isPresented: self.$showImagePicker) {
            ImagePicker(image: self.$profileImage, takePhoto: self.$takePhoto)
        }
        .navigationBarTitle("My Profile", displayMode: .inline)
        .navigationBarItems(trailing: Button("Save") {
            let streamUser = self.user.streamClient?.streamUser
            streamUser?.firstName = self.firstName
            streamUser?.lastName = self.lastName
            streamUser?.city = self.city
            streamUser?.state = self.state
            streamUser?.bio = self.bio
            self.user.streamClient?.UpdateUserProfile(user: streamUser!, profileImage: self.profileImage)
            self.presentationMode.wrappedValue.dismiss()
        }).onAppear(perform: {
            if let temp = self.user.streamClient?.streamUser {
                self.firstName = temp.firstName ?? ""
                self.lastName = temp.lastName ?? ""
                self.city = temp.city ?? ""
                self.state = temp.state ?? ""
                self.bio = temp.bio ?? ""
                self.imgURL = temp.imgURL
            }
        })
    }
}
