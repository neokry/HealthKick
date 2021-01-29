//
//  StreamClient.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/5/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import GetStream
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFunctions
import Combine
import SwiftUI

enum FeedType {
    case profile, timeline
}

class StreamClient: ObservableObject {
    @Published var feedUsers = [String]()
    @Published var userList = [UserListEntry]()
    @Published var streamUser: StreamUser?
    @Published var userLoaded = false
    @Published var timelineStream: StreamInfiniteScroll?
    @Published var userStream: StreamInfiniteScroll?
    var userFeed: GetStream.FlatFeed?
    var timelineFeed: GetStream.FlatFeed?
    var notificationsFeed: GetStream.NotificationFeed?
    var notificationItems: [NotificationGroup<ReactionItem>]?
    var token: String = ""
    var userID: String
    var isFirstLoad = false
    var isLoadedSem: DispatchSemaphore
    var db = Firestore.firestore()
    lazy var functions = Functions.functions()

    init(userID: String, isLoadedSem: DispatchSemaphore) {
        self.userID = userID
        self.isLoadedSem = isLoadedSem
        GetUserToken()
    }

    func UpdateUserProfile(user: StreamUser, profileImage: UIImage?) {
        if let img = profileImage {
            CheckProfileImage(userID: user.id, img: img) { success, url in
                if success {
                    user.imgURL = url
                }
                self.UpdateUser(user: user)
            }
        } else {
            self.UpdateUser(user: user)
        }
    }

    func UpdateUser(user: StreamUser) {

        Client.shared.update(user: user) { result in
            switch result {
            case .failure(let err):
                print("Error updating user profile \(err)")
            case .success(let temp):
                self.streamUser = temp
                self.UpdateFirebaseInfo(user: self.streamUser!)
                Analytics.logEvent("updated_profile", parameters: nil)
            }
        }
    }

    func UpdateFirebaseInfo(user: StreamUser) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        let name = "\(user.firstName ?? "") \(user.lastName ?? "")"
        changeRequest?.displayName = name
        changeRequest?.photoURL = user.imgURL
        changeRequest?.commitChanges { err in
            if err != nil {
                print("Error updating firebase info")
            }
        }
    }

    func CheckProfileImage(userID: String, img: UIImage, completion: @escaping (Bool, URL?) -> Void) {
        if let oldImg = streamUser?.imgURL {
            Client.shared.delete(imageURL: oldImg) { result in
                switch result {
                case .failure(let err):
                    print("Error deleting old profile image \(err)")
                case .success:
                    self.UploadProfileImage(userID: userID, img: img) { success, URL in
                        completion(success, URL)
                    }
                }
            }
        } else {
            UploadProfileImage(userID: userID, img: img) { success, URL in
                completion(success, URL)
            }
        }
    }

    func UploadProfileImage(userID: String, img: UIImage, completion: @escaping (Bool, URL?) -> Void) {
        if let file = File(name: "\(userID)ProfilePicture.jpg", jpegImage: img, compressionQuality: 0.9) {
            Client.shared.upload(image: file) { result in
                switch result {
                case .failure(let err):
                    print("Error uploading profile image \(err)")
                    completion(false, nil)
                case .success(let url):
                    Client.shared.resizeImage(imageProcess: ImageProcess(url: url, resize: .crop, width: 100, height: 100)) { resizeResult in
                        switch resizeResult {
                        case .failure(let err):
                            print("Error resizing profile img \(err)")
                        case .success(let urlSmall):
                            completion(true, urlSmall)
                        }
                    }
                }
            }
        }
    }

    func IsFollowing(userID: String, completion: @escaping (Bool) -> Void) {
        timelineFeed?.following(filter: [FeedId(feedSlug: "user", userId: userID)], limit: 1) { result in
            switch result {
            case .failure(let err):
                print("Error checking follow status \(err)")
            case .success(let isFollow):
                completion(isFollow.results.count > 0)
            }
        }
    }

    func UnfollowUser(user: StreamUser, completion: @escaping (Bool) -> Void) {
        let feedID = Client.shared.flatFeed(feedSlug: "user", userId: user.id).feedId
        timelineFeed!.unfollow(fromTarget: feedID) { result in
            switch result {
            case .failure(let err):
                print("Error unfollowing user \(err)")
                completion(false)
            case .success:
                Analytics.logEvent("unfollowed_user", parameters: nil)
                user.followersCount = user.followersCount! - 1
                self.streamUser?.followingCount = (self.streamUser?.followingCount)! - 1

                completion(true)
            }
        }
    }

    func FollowUser(user: StreamUser, completion: @escaping (Bool) -> Void) {
        let feedID = FeedId(feedSlug: "user", userId: user.id)
        timelineFeed!.follow(toTarget: feedID) { result in
            switch result {
            case .failure(let err):
                print("Error following user \(err)")
                completion(false)
            case .success:
                Analytics.logEvent("followed_user", parameters: nil)
                completion(true)
            }
        }
    }

    func GetUser(userID: String, completion: @escaping (Bool, StreamUser?) -> Void) {
        Client.shared.get(typeOf: StreamUser.self, userId: userID, withFollowCounts: true) { result in
            switch result {
            case .failure(let err):
                print("Error getting user \(err)")
                completion(false, nil)
            case .success(let user):
                completion(true, user)
            }
        }
    }

    func GetUsers() {
        let url = URL(string: "https://us-central1-health-kick-a3832.cloudfunctions.net/getUsersList")!
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode([UserListEntry].self, from: data)
                    DispatchQueue.main.async {
                        self.userList = decodedResponse
                        Analytics.logEvent("checked_user_list", parameters: nil)
                    }
                } catch {
                    print("Error \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    func UploadFeedImage(img: UIImage, completion: @escaping (Bool, URL?) -> Void) {
        if let file = File(name: "\(userID)\(UUID().uuidString).jpg", jpegImage: img, compressionQuality: 0.3) {
            Client.shared.upload(image: file) { result in
                switch result {
                case .failure(let err):
                    print("Error uploading image \(err)")
                    completion(false, nil)
                case .success(let url):
                    completion(true, url)
                }
            }
        }
    }

    func UploadActivity(activity: FeedItem, completion: @escaping (Bool) -> Void) {
        guard let feed = userFeed else {
            fatalError("Feed not initilized")
        }

        feed.add(activity) { result in
            switch result {
            case .failure(let err):
                print("Error posting to feed \(err)")
                completion(false)
            case .success(let activity):
                self.userStream?.feedItems.insert(activity, at: 0)
                Analytics.logEvent("made_post", parameters: nil)
                completion(true)
            }
        }
    }

    func AddToFeed(img: UIImage?, caption: String, recipeID: String?, completion: @escaping (Bool) -> Void) {
        if let temp = img {
            UploadFeedImage(img: temp) { success, URL in
                var activity: FeedItem
                if success {
                    activity = FeedItem(actor: self.streamUser!, verb: "post", object: UUID().uuidString, imgURL: URL, caption: caption, recipeID: recipeID)
                } else {
                    activity = FeedItem(actor: self.streamUser!, verb: "post", object: UUID().uuidString, imgURL: nil, caption: caption, recipeID: recipeID)
                }
                self.UploadActivity(activity: activity) { success in
                    completion(success)
                }
            }
        } else {
            let activity = FeedItem(actor: self.streamUser!, verb: "post", object: UUID().uuidString, imgURL: nil, caption: caption, recipeID: recipeID)
            UploadActivity(activity: activity) { success in
                completion(success)
            }
        }
    }

    func RemoveFromFeed(activity: FeedItem) {
        if let oldImg = activity.imgURL {
            Client.shared.delete(imageURL: oldImg) { result in
                switch result {
                case .failure(let err):
                    print("Error deleting old profile image \(err)")
                case .success:
                    break
                }
                self.RemoveActivity(activityID: activity.id)
            }
        } else {
            self.RemoveActivity(activityID: activity.id)
        }
    }

    func RemoveActivity(activityID: String) {
        guard let feed = userFeed else {
            fatalError("Feed not initilized")
        }

        feed.remove(activityId: activityID) { result in
            switch result {
            case .failure(let err):
                print("Error removing from feed \(err)")
            case .success:
                let idx = self.userStream?.feedItems.firstIndex(where: { $0.id == activityID})
                if let idx = idx {
                    self.userStream?.feedItems.remove(at: idx)
                }
            }
        }
    }

    func LikeActivity(activityID: String, id: String, likes: LikeCache, postUserID: String) {
        var lCache = likes
        Client.shared.add(reactionTo: activityID, kindOf: .like, targetsFeedIds: [FeedId(feedSlug: "notification", userId: postUserID)]) { result in
            switch result {
            case .failure(let err):
                print("Error liking activity \(err)")
            case .success(let reaction):
                lCache[activityID] = reaction.id
                Analytics.logEvent("liked_post", parameters: nil)
                break
            }
        }
    }

    func RemoveLike(reactionID: String, activityID: String, likes: LikeCache) {
        var lCache = likes
        Client.shared.delete(reactionId: reactionID) { result in
            switch result {
            case .failure(let err):
                print("Error removing like from activity \(err)")
            case .success:
                lCache[activityID] = nil
                break
            }
        }
    }

    func GetComments(activityID: String, completion: @escaping(Reactions<Comment, StreamUser>) -> Void) {
        Client.shared.reactions(forActivityId: activityID, kindOf: .comment, extraDataTypeOf: Comment.self, userTypeOf: StreamUser.self, pagination: .limit(10)) { result in
            switch result {
            case .failure(let err):
                print("Error loading comments \(err)")
            case .success(let comments):
                completion(comments)
            }
        }
    }

    func AddComment(activityID: String, userComment: String, postUserID: String, completion: @escaping (Bool, Reaction<Comment, StreamUser>?) -> Void) {
        Client.shared.add(reactionTo: activityID, kindOf: .comment, extraData: Comment(text: userComment), userTypeOf: StreamUser.self, targetsFeedIds: [FeedId(feedSlug: "notification", userId: postUserID)]) { result in
            switch result {
            case .failure(let err):
                completion(false, nil)
                print("Error commenting to post \(err)")
            case .success(let comment):
                Analytics.logEvent("commented_post", parameters: ["comment_length": userComment.count])
                completion(true, comment)
                break
            }
        }
    }

    func GetUserToken() {
        let tokenRef = db.collection("userStreamTokens").document(self.userID)
        tokenRef.getDocument { (doc, err) in
            if err != nil || !(doc?.exists ?? false) {
                self.GenerateNewToken()
            } else {
                self.token = doc?.get("token") as! String
                self.initStreams()
            }
        }
    }

    func GenerateNewToken() {
        var firstName = ""
        var lastName = ""
        if let user = Auth.auth().currentUser {
            if let userName = user.displayName {
                let split = userName.split(separator: " ")
                firstName = split[0].trimmingCharacters(in: .whitespacesAndNewlines)
                lastName = split[1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        functions.httpsCallable("createStreamToken").call(["UID": self.userID, "firstName": firstName, "lastName": lastName]) { (result, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
                fatalError("Could not generate GetStream token for user \(self.userID)")
            }

            if let tokenResult = (result?.data as? [String: Any])?["token"] as? String {
                self.token = tokenResult
                self.isFirstLoad = true
                self.initStreams()
            }
        }
    }

    func followOfficalAccount() {
        Client.shared.get(typeOf: StreamUser.self, userId: "B0kK345rfxRj2kjle0JalbdFHVt1", withFollowCounts: true) { userResult in
            switch userResult {
            case .success(let user):
                self.FollowUser(user: user) { _ in
                    self.initInfiniteScroll()
                }
            case .failure(let err):
                print("Error following offical account \(err)")
                self.initInfiniteScroll()
            }
        }
    }

    func initInfiniteScroll() {
        self.timelineStream = StreamInfiniteScroll(.timeline)
        self.timelineStream?.loadPosts {
            self.isLoadedSem.signal()
        }

        self.userStream = StreamInfiniteScroll(.profile)
        self.userStream?.loadPosts {
            return
        }
    }

    func initNotificationFeed() {
        notificationsFeed?.get(typeOf: ReactionItem.self, includeReactions: [.counts]) { result in
            switch result {
            case .success(let notifications):
                self.notificationItems = notifications.results
            case .failure(let err):
                print("Error getting notification feed \(err)")
            }
        }
    }

    func initStreams() {
        Client.shared.setupUser(token: self.token) { result in
            switch result {
            case .success:
                if !self.isFirstLoad {
                    self.initInfiniteScroll()
                }

                Client.shared.get(typeOf: StreamUser.self, userId: self.userID, withFollowCounts: true) { userResult in
                    switch userResult {
                    case .success(let user):
                        self.streamUser = user
                        self.userFeed = Client.shared.flatFeed(feedSlug: "user", userId: user.id)
                        self.timelineFeed = Client.shared.flatFeed(feedSlug: "timeline", userId: user.id)
                        self.notificationsFeed = Client.shared.notificationFeed(feedSlug: "notification", userId: user.id)
                        self.initNotificationFeed()

                        if self.isFirstLoad {
                            self.followOfficalAccount()
                        }

                    case .failure(let err):
                        fatalError("Could not find stream user \(err)")
                    }
                }

            case .failure(let error):
                fatalError("Error setting up user \(error.localizedDescription)")
            }
        }
    }
}

typealias ReactionItem = EnrichedActivity<StreamUser, FeedItem, Reaction<ReactionExtraData, StreamUser>>

public struct Comment: ReactionExtraDataProtocol {
    public let text: String
}

struct UserListEntry: Identifiable, Codable {
    var id: String
    var email: String
    var name: String?
    var imgURL: URL?
}

protocol LikeCache {
    subscript(_ post: String) -> String? { get set }
}

struct TempLikeCache: LikeCache {
    private let cache = NSMutableDictionary()

    subscript(_ key: String) -> String? {
        get { cache.object(forKey: key as NSString) as? String }
        set { newValue == nil ? cache.removeObject(forKey: key as NSString) : cache.setObject(newValue!, forKey: key as NSString) }
    }
}

struct LikeCacheKey: EnvironmentKey {
    static let defaultValue: LikeCache = TempLikeCache()
}

extension EnvironmentValues {
    var likeCache: LikeCache {
        get { self[LikeCacheKey.self] }
        set { self[LikeCacheKey.self] = newValue }
    }
}
