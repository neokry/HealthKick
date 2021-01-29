//
//  StreamView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/6/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Introspect

struct UserStreams: View {
    @EnvironmentObject var user: AppUser

    var body: some View {
        NavigationView {
            if user.streamClient != nil {
                StreamView()
                    .environmentObject(user.streamClient!)
            } else {
                EmptyView()
            }
        }
    }
}

struct StreamView: View {
    @Environment(\.imageCache) var cache: ImageCache
    @EnvironmentObject var user: AppUser
    @EnvironmentObject var streamClient: StreamClient
    @State private var streamSelection = 0
    @State private var showNewPost = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.showNewPost = true
                }) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23)
                        .foregroundColor(Color.black)
                }

                Spacer()

                Text("Your Feed")

                Spacer()

                NavigationLink(destination: StreamNotifications()
                        .navigationBarTitle(" ")
                        .navigationBarHidden(true)
                        .environmentObject(streamClient)) {
                    Image(systemName: "bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(Color.black)
                }
            }
            .padding(.horizontal, 10)

            Divider()

            Picker("Pick a stream", selection: self.$streamSelection) {
                Text("Following").tag(0)
                Text("You").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())

            ZStack {
                if streamClient.timelineStream != nil {
                    ActivityStream(streamClient: self.streamClient, isSelf: false)
                        .opacity(self.streamSelection == 0 ? 1:0)
                }

                if streamClient.userStream != nil {
                    ActivityStream(streamClient: self.streamClient, isSelf: true)
                        .opacity(self.streamSelection == 1 ? 1:0)
                }
            }.animation(nil)

            Spacer()
        }
        .sheet(isPresented: self.$showNewPost) {
            StreamCreatePostView().environmentObject(self.user)
        }
        .navigationBarTitle(" ")
        .navigationBarHidden(true)
    }
}

struct ActivityStream: View {
    @ObservedObject var stream: StreamInfiniteScroll
    var isSelf = false

    var body: some View {
        GeometryReader { geo in
            List(self.stream.feedItems) { item in
                FeedItemView(item: item, isSelf: self.isSelf, width: geo.size.width)
                    .onAppear(perform: {
                        if self.stream.shouldLoad(item: item) {
                            self.stream.loadPosts {
                                return
                            }
                        }
                    })
                    .padding(.vertical, 10)
            }.introspectTableView { table in
                table.showsVerticalScrollIndicator = false
            }
            .listStyle(PlainListStyle())
        }
    }

    init(streamClient: StreamClient, isSelf: Bool) {
        if isSelf {
            stream = streamClient.userStream!
        } else {
            stream = streamClient.timelineStream!
        }
        self.isSelf = isSelf
    }
}

struct ProfilePlaceHolder: View {
    var body: some View {
        Circle()
            .foregroundColor(.gray)
            .frame(width: 65, height: 65)
    }
}

struct ImagePlacerHolder: View {
    var text = "Loading..."

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color("LoadingBackgroundColor"))
                .frame(height: 300)

            Text(text)
                .foregroundColor(Color.gray.opacity(0.4))
        }
    }
}
