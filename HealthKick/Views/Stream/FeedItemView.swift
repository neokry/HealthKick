//
//  FeedItemView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 7/3/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

enum feedItemSheetContent {
    case recipe, picture
}

struct FeedItemProperties {
    var showingActionSheet = false
    var showingSheet = false
    var showDetails = false
    var sheetContent = feedItemSheetContent.recipe
    var nav: AnyView = AnyView(EmptyView())
    var showNav = false
}

struct FeedItemView: View {
    @Environment(\.imageCache) var cache: ImageCache
    @Environment(\.likeCache) var likes: LikeCache
    @EnvironmentObject var user: AppUser
    @EnvironmentObject var streamClient: StreamClient
    @State private var feedItemProps = FeedItemProperties()
    var item: FeedItem
    var isSelf = false
    var width: CGFloat
    
    var recipe: ImportedRecipe? {
        return user.userRecipes?.first(where: { $0.id == item.recipeID })
    }
    
    var loadedImage: UIImage? {
        if let img = user.cloudImageCache[item.recipeID ?? ""] {
            return img
        } else if let url = recipe?.imageURL {
            if let img = cache[url] {
                return img
            }
        }

        return nil
    }

    init(item: FeedItem, isSelf: Bool, width: CGFloat) {
        self.item = item
        self.isSelf = isSelf
        self.width = width

    }

    var body: some View {
        ZStack {
            NavigationLink(destination: self.feedItemProps.nav.onDisappear(perform: {
                self.feedItemProps.nav = AnyView(StreamProfileView(streamClient: self.streamClient, userFeed: StreamInfiniteScroll(.profile, id: self.item.actor.id), userID: self.item.actor.id).navigationBarTitle(" ").navigationBarHidden(true))
            }), isActive: self.$feedItemProps.showNav) {
                EmptyView()
            }

            VStack(alignment: .leading) {

                FeedItemHeaderView(feedItemProps: self.$feedItemProps, isSelf: self.isSelf, item: self.item)

                FeedItemContentView(feedItemProps: self.$feedItemProps, item: self.item)

                FeedItemControlsView(feedItemProps: self.$feedItemProps, item: self.item, width: self.width)

            }
        }
        .onAppear(perform: {
            self.feedItemProps.nav = AnyView(StreamProfileView(streamClient: self.streamClient, userFeed: StreamInfiniteScroll(.profile, id: self.item.actor.id), userID: self.item.actor.id).navigationBarTitle(" ").navigationBarHidden(true))
        })
        .sheet(isPresented: self.$feedItemProps.showingSheet) {
            if self.feedItemProps.sheetContent == .recipe {
                RecipeDetailLoader(recipe: self.recipe ?? ImportedRecipe(), loadedImage: self.loadedImage != nil ? Image(uiImage: self.loadedImage!) : nil)
                    .environmentObject(self.user)
            } else {
                AsyncImage(url: self.item.imgURL!, cache: self.cache, placeholder: ImagePlacerHolder())
                    .aspectRatio(contentMode: .fit)
            }
        }
        .actionSheet(isPresented: self.$feedItemProps.showingActionSheet) {
            ActionSheet(title: Text("Post Settings"), message: nil, buttons: [.default(Text("Edit")), .destructive(Text("Delete"), action: {
                self.streamClient.RemoveFromFeed(activity: self.item)
            }), .cancel()])
        }
    }
}

struct FeedItemLikeControlView: View {
    @Environment(\.likeCache) var likes: LikeCache
    @EnvironmentObject var streamClient: StreamClient
    @State var isLiked = false
    @State var isEdited = false
    var item: FeedItem

    var body: some View {
        Image(systemName: self.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
            .onTapGesture {
                if self.isLiked && self.item.userLikedReaction != nil {
                    self.streamClient.RemoveLike(reactionID: self.item.userLikedReaction!.id, activityID: self.item.id, likes: self.likes)
                } else if self.isLiked && self.likes[self.item.id] != nil {
                    self.streamClient.RemoveLike(reactionID: self.likes[self.item.id]!, activityID: self.item.id, likes: self.likes)
                } else {
                    self.streamClient.LikeActivity(activityID: self.item.id, id: self.item.actor.id, likes: self.likes, postUserID: self.item.actor.id)
                }
                self.isLiked.toggle()
                self.isEdited = true
            }
            .foregroundColor(self.isLiked ? Color.green : Color.black)
            .onAppear(perform: {
                if self.isEdited {
                    self.isLiked = self.likes[self.item.id] != nil
                } else {
                    self.isLiked = self.item.isUserLiked
                }
            })
    }
}

struct FeedItemControlsView: View {
    @EnvironmentObject var streamClient: StreamClient
    @Binding var feedItemProps: FeedItemProperties
    var item: FeedItem
    var width: CGFloat

    var body: some View {
        HStack {
            Group {
                Spacer()

                FeedItemLikeControlView(item: self.item)

                Spacer()
            }

            Divider()

            Group {
                Spacer()
                Image(systemName: "text.bubble")
                    .renderingMode(.original)
                    .foregroundColor(.black)
                    .onTapGesture {
                        self.feedItemProps.nav = AnyView(StreamComments(streamClient: self.streamClient, item: self.item).navigationBarTitle(" ").navigationBarHidden(true))
                        self.feedItemProps.showNav = true
                }
                Spacer()
            }

            Divider()

            Group {
                if self.item.recipeID != nil {
                    Spacer()
                    Image("recipe")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .onTapGesture {
                            self.feedItemProps.showingSheet = true
                            self.feedItemProps.sheetContent = .recipe
                    }
                    Spacer()

                    Divider()
                }
            }

            Group {
                Spacer()
                Image(systemName: "square.and.arrow.up")
                Spacer()
            }

        }
        .frame(width: self.width * 0.9, height: 30)
    }
}

struct FeedItemContentView: View {
    @Environment(\.imageCache) var cache: ImageCache
    @Binding var feedItemProps: FeedItemProperties
    var item: FeedItem

    var body: some View {
        Group {
            if self.item.caption != nil {
                Text(self.item.caption!)
                    .lineLimit(4)
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxHeight: 200)
            }

            if self.item.imgURL != nil {
                AsyncImage(url: self.item.imgURL!, cache: self.cache, placeholder: ImagePlacerHolder())
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .contentShape(RoundedRectangle(cornerRadius: 20))
                    .onTapGesture {
                        self.feedItemProps.showingSheet = true
                        self.feedItemProps.sheetContent = .picture
                    }
            }

            HStack {
                if self.item.likesCount > 0 {
                    Text("\(self.item.likesCount) inspired")
                        .font(.caption)
                        .padding(.leading, 10)
                }

                Spacer()

                /*
                if self.item.commentsCount > 0 {
                    Text("\(self.item.commentsCount) comments")
                        .font(.caption)
                        .padding(.trailing, 10)
                }
 */
            }
        }
    }
}

struct FeedItemHeaderView: View {
    @EnvironmentObject var streamClient: StreamClient
    @Environment(\.imageCache) var cache: ImageCache
    @Binding var feedItemProps: FeedItemProperties
    var isSelf: Bool
    var item: FeedItem

    var body: some View {
        HStack(alignment: .top) {
            if self.item.actor.imgURL != nil {
                AsyncImage(url: self.item.actor.imgURL!, cache: self.cache, placeholder: ProfilePlaceHolder())
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .padding(.trailing, 5)
                    .onTapGesture {
                        self.feedItemProps.nav = AnyView(StreamProfileView(streamClient: self.streamClient, userFeed: StreamInfiniteScroll(.profile, id: self.item.actor.id), userID: self.item.actor.id).navigationBarTitle(" ").navigationBarHidden(true))
                        self.feedItemProps.showNav = true
                }
            }

            VStack(alignment: .leading) {
                Text("\(self.item.actor.firstName ?? "Null") \(self.item.actor.lastName ?? "Null")")
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(.bottom, 5)

                Text("\(self.item.friendlyTime)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
            if isSelf {
                Text("...").font(.title).onTapGesture {
                    self.feedItemProps.showingActionSheet = true
                }

            }
        }
    }
}
