//
//  SearchResultListAsync.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/25/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI
import Combine
import Foundation
import os
import FirebaseAnalytics
import GetStream

enum PageStatus {
    case ready (lastID: String?)
    case loading (lastID: String?)
    case done
}

enum SearchError: Error {
    case limitError
    case httpError
}

class StreamInfiniteScroll: ObservableObject {
    @Environment(\.imageCache) var cache: ImageCache
    @Published var feedItems = [FeedItem]()
    @Published var endOfList = false
    var pageStatus = PageStatus.ready(lastID: nil)
    var feedRef: FlatFeed?
    var imageLoaderList = [ImageLoader]()

    static let ResultsPerPage = 3

    init(_ type: FeedType, id: String? = nil) {
        if let id = id {
            feedRef = Client.shared.flatFeed(feedSlug: "user", userId: id)
        } else {
            if let userID = Client.shared.currentUser?.id {
                switch type {
                case .profile:
                    feedRef = Client.shared.flatFeed(feedSlug: "user", userId: userID)
                case .timeline:
                    feedRef = Client.shared.flatFeed(feedSlug: "timeline", userId: userID)
                }
            }
        }
    }

    func loadPosts(completion: @escaping () -> Void) {
        guard case let .ready(lastID) = pageStatus else {
            return
        }

        pageStatus = .loading(lastID: lastID)
        var pageSetting = Pagination.limit(5)
        if let lastID = lastID {
            pageSetting = Pagination.lessThan(lastID) + Pagination.limit(5)
        }

        feedRef?.get(typeOf: FeedItem.self, pagination: pageSetting, includeReactions: [.own, .counts]) { result in
            switch result {
            case .failure(let err):
                print("Error loading posts \(err)")
                self.pageStatus = .done
                break
            case .success:
                do {
                    let items = try result.get().results
                    if items.count > 0 {

                        let group = DispatchGroup()

                        for item in items {
                            if let url = item.imgURL {
                                if self.cache[url] == nil {
                                    group.enter()
                                    let loader = ImageLoader(url: url, cache: self.cache)
                                    loader.load {
                                        group.leave()
                                    }
                                }
                            }
                        }

                        group.notify(queue: .main, execute: {
                            self.pageStatus = PageStatus.ready(lastID: items.last?.id)
                            self.feedItems.append(contentsOf: items)
                            completion()
                        })

                    } else {
                        self.pageStatus = .done
                    }

                } catch {
                    print("Error loading posts \(error.localizedDescription)")
                }
            }
        }
    }

    func shouldLoad(item: FeedItem) -> Bool {
        if let lastID = feedItems.last?.id {
            if item.id == lastID {
                return true
            } else {
                return false
            }
        }

        return false
    }
}
