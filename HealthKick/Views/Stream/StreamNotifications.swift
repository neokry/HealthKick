//
//  StreamNotifications.swift
//  HealthKick
//
//  Created by Patrick Genevich on 7/5/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import GetStream

struct StreamNotifications: View {
    @EnvironmentObject var streamClient: StreamClient
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Group {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14)
                        .foregroundColor(Color.black)
                }

                Spacer()

                Text("Notifications")

                Spacer()
            }
            .padding(.horizontal, 10)

            Divider()

            if streamClient.notificationItems != nil {
                List {
                    ForEach(streamClient.notificationItems!, id: \.id) { notification in
                        NotificationItem(notification: notification)
                    }
                }
            } else {
                VStack {
                    Spacer()

                    Text("Your notifications")
                        .font(.headline)
                        .padding(.bottom, 10)

                    Text("All of your important updates from friends and followers will be displayed here.")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Spacer()
                }
            }
        }
    }
}

struct NotificationItem: View {
    @Environment(\.imageCache) var cache: ImageCache
    var notification: NotificationGroup<ReactionItem>
    var firstUser: StreamUser {
        notification.activities.first!.actor
    }
    var notificationText: String {
        var nt = firstUser.fullName ?? ""
        if notification.activitiesCount > 1 {
            nt += " and \(notification.activitiesCount) others"
        }
        if notification.verb == "like" {
            nt += " liked your post"
        } else if notification.verb == "comment" {
            nt += " commented on your post"
        }
        return nt
    }

    var body: some View {
        HStack {
            if firstUser.imgURL != nil {
                AsyncImage(url: firstUser.imgURL!, cache: cache, placeholder: Text(" "))
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
            Text(notificationText)
        }
    }
}
