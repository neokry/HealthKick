//
//  StreamProfileView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/6/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

struct StreamProfileHeader: View {
    @ObservedObject var streamClient: StreamClient
    @State var showUserList = false
    @State var isFollowing = false
    @Environment(\.imageCache) var cache: ImageCache
    var streamUser: StreamUser
    var isSelf = true

    var body: some View {
        VStack {
            HStack {
                if streamUser.imgURL != nil {
                    AsyncImage(url: streamUser.imgURL!, cache: cache, placeholder: Text(" "))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                        .padding(.trailing, 5)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: 65, height: 65)
                        .padding(.trailing, 5)

                }

                VStack(alignment: .leading) {
                    Text("\(streamUser.firstName ?? "") \(streamUser.lastName ?? "")")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)

                    Text("\(streamUser.city ?? "") \(streamUser.city != nil && streamUser.state != nil ? "," : " ") \(streamUser.state ?? "")")
                        .font(.caption)
                        .padding(.bottom, 5)

                    Text("\(streamUser.bio ?? "")")
                        .font(.caption)
                }

                Spacer()
            }

            HStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(streamUser.followingCount ?? 0)")
                        Text("Following")
                            .foregroundColor(.gray)
                    }

                    Divider()
                        .frame(height: 20)
                        .padding([.leading, .trailing], 5)

                    VStack(alignment: .leading) {
                        Text("\(streamUser.followersCount ?? 0)")
                        Text("Folowers")
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Group {
                    Button(action: {
                        if self.isSelf {
                            self.streamClient.GetUsers()
                            self.showUserList = true
                        } else {
                            if self.isFollowing {
                                self.streamClient.UnfollowUser(user: self.streamUser) { result in
                                    self.isFollowing = !result
                                }
                            } else {
                                self.streamClient.FollowUser(user: self.streamUser) { result in
                                    self.isFollowing = result
                                }
                            }
                        }
                    }) {
                        Text(self.isSelf ? "Add Friends" : self.isFollowing ? "Unfollow" : "Follow")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .background(Color.white
                                .frame(width: 100, height: 30)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.green)))
                    }
                }

            }
            /*
            NavigationLink(destination: StreamAddFriendsView(streamClient: self.streamClient, searchText: ), isActive: self.$showUserList) {
                EmptyView()
            }
 */
        }
        .padding(.top, 5)
        .padding(.trailing, 30)
        .padding(.bottom, -5)
    }
}
