//
//  StreamComments.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/18/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import GetStream

struct StreamComments: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.imageCache) var cache: ImageCache
    @ObservedObject private var keyboard = KeyboardResponder()
    @ObservedObject var streamClient: StreamClient
    @State private var comment = ""
    @State var comments: [Reaction<Comment, StreamUser>]?
    var item: FeedItem

    var body: some View {
        VStack {
            Group{
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

                    Text("Comments")

                    Spacer()

                }
                .padding(.horizontal, 10)
                .padding(.vertical, 15)
            }
            .background(Color.white)

            ScrollView {
                if comments?.count ?? 0 > 0 {
                    ForEach(comments!, id: \.id) { userComment in
                        HStack(alignment: .top) {
                            AsyncImage(url: userComment.user.imgURL!, cache: self.cache, placeholder: ImagePlacerHolder())
                               .aspectRatio(contentMode: .fill)
                               .frame(width: 45, height: 45)
                               .clipShape(Circle())
                                .padding([.leading, .trailing], 5)

                            VStack(alignment: .leading) {
                                Text("\(userComment.user.firstName ?? "")  \(userComment.user.lastName ?? "") - \(self.GetFriendlyDate(date: userComment.created))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 5)

                                Text(userComment.data.text)
                                    .font(.body)
                                    .padding(.bottom, 15)

                                if userComment != self.comments!.last {
                                    Divider()
                                }
                            }

                            Spacer()

                        }
                        .padding(.top, 5)
                    }
                    .onDelete(perform: delete)
                    .background(Color.white)
                }
            }

            HStack {
                TextField("Comment", text: self.$comment)
                    .padding(10)

                Button("Send") {
                    self.streamClient.AddComment(activityID: self.item.id, userComment: self.comment, postUserID: self.item.actor.id) { success, comment in
                        if success {
                            withAnimation {
                                self.comments?.insert(comment!, at: 0)
                            }
                            self.comment = ""
                        }
                    }
                }
                .padding(.trailing, 10)
                .foregroundColor(.gray)
            }
            .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 10)))
            .padding([.leading, .trailing], 5)
        }
        .onAppear(perform: {
            self.streamClient.GetComments(activityID: self.item.id) { result in
                withAnimation {
                    self.comments = result.reactions
                }
            }
        })
        .padding(.bottom, keyboard.currentHeight > 0 ? keyboard.currentHeight - 40 : 25)
        .animation(.easeOut(duration: 0.16))
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.gray.opacity(0.2))
    }

    func delete(at offsets: IndexSet) {
        //users.remove(atOffsets: offsets)
    }

    func GetFriendlyDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        let d = formatter.string(from: date)
        return "\(d)"
    }
}
