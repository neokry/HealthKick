//
//  StreamProfileView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/11/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct StreamProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var streamClient: StreamClient
    @ObservedObject var userFeed: StreamInfiniteScroll
    @State var user: StreamUser?
    @State var isFollowing: Bool?
    var userID: String

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10)
                        .foregroundColor(Color.black)
                }

                Spacer()

                Text("Profile")

                Spacer()

            }
            .padding(.horizontal, 10)
            .padding(.top, 15)

            Divider()

            GeometryReader { geo in
                List{
                    if self.user != nil && self.isFollowing != nil {
                        StreamProfileHeader(streamClient: self.streamClient, isFollowing: self.isFollowing!, streamUser: self.user!, isSelf: false)
                    }
                    
                    ForEach(self.userFeed.feedItems) { item in
                        FeedItemView(item: item, isSelf: false, width: geo.size.width)
                            .environmentObject(self.streamClient)
                            .onAppear(perform: {
                                if self.userFeed.shouldLoad(item: item) {
                                    self.userFeed.loadPosts {
                                        return
                                    }
                                }
                            })
                            .padding(.vertical, 10)
                    }
                }.introspectTableView { table in
                    table.showsVerticalScrollIndicator = false
                }
            }
        }.onAppear(perform: LoadProfile)
    }

    func LoadProfile() {
        self.streamClient.GetUser(userID: self.userID) { success, user in
            if success {
                self.user = user
            }
        }

        self.userFeed.loadPosts {
            return
        }

        self.streamClient.IsFollowing(userID: self.userID) { result in
            self.isFollowing = result
        }
    }
}
