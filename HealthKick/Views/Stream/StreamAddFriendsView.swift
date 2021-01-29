//
//  StreamAddUsersView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/8/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct StreamAddFriendsView: View {
    @Environment(\.imageCache) var cache: ImageCache
    @ObservedObject var streamClient: StreamClient
    @State private var showUser = false
    @State private var selectedUser = ""
    @Binding var searchText: String

    var body: some View {
        VStack {
            List {
                ForEach(self.streamClient.userList.filter({ searchText.count > 0 ? ($0.name ?? $0.email).lowercased().contains(self.searchText.lowercased()) : true })) { user in
                    Button(action: {
                        self.showUser = true
                        self.selectedUser = user.id
                    }) {
                        HStack {
                            if user.imgURL != nil {
                                AsyncImage(url: user.imgURL!, cache: self.cache, placeholder: Text(" "))
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 45, height: 65)
                                    .clipShape(Circle())
                                    .padding(.trailing, 5)
                            } else {
                                Circle()
                                    .frame(width: 45, height: 65)
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 5)
                            }
                            Text(user.name ?? user.email)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())

            NavigationLink(destination: StreamProfileView(streamClient: self.streamClient, userFeed: StreamInfiniteScroll(.profile, id: self.selectedUser), userID: self.selectedUser).navigationBarTitle(" ").navigationBarHidden(true), isActive: self.$showUser) {
                EmptyView()
            }
        }
        .onAppear(perform: {self.streamClient.GetUsers()})
        .navigationBarTitle(" ")
        .navigationBarHidden(true)
    }
}
