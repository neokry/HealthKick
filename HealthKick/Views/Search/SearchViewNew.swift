//
//  SearchViewNew.swift
//  HealthKick
//
//  Created by Patrick Genevich on 7/8/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct SearchViewNew: View {
    @Environment(\.imageCache) var cache: ImageCache
    @EnvironmentObject var user: AppUser
    @State var showSheet = false
    @State var showSettings = false
    @State var signOut = false
    @State var searchText = ""
    @State var loadSearchResults = false

    var body: some View {
        NavigationView {
            VStack {
                if self.user.streamClient != nil && self.user.streamClient?.streamUser != nil {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search for friends", text: self.$searchText, onEditingChanged: {(changed) in self.loadSearchResults = !changed})
                        }
                        .padding(10)
                        .background(Color.gray.clipShape(RoundedRectangle(cornerRadius: 10)).opacity(0.2))
                        .padding(10)
                    }
                    .padding(.horizontal, 10)

                    Divider()
                    if self.user.streamClient != nil {
                        StreamAddFriendsView(streamClient: self.user.streamClient!, searchText: self.$searchText)
                    }
                }
            }
        }
        .navigationBarTitle(" ")
        .navigationBarHidden(true)
        .sheet(isPresented: self.$showSheet) {
            if self.showSettings {
                SettingsView(signOut: self.$signOut).environmentObject(self.user)
                .onDisappear(perform: {
                    if self.signOut {
                        self.user.signOut()
                    }
                })
            } else {
                StreamEditProfileView().environmentObject(self.user)
            }
        }
    }
}
