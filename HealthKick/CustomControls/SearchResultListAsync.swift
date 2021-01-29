//
//  SearchResultListAsync.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/25/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

/*
import SwiftUI
import Combine
import Foundation
import os
import FirebaseAnalytics

enum PageStatus {
    case ready (nextPage: Int)
    case loading (page: Int)
    case done
}

enum SearchError: Error {
    case limitError
    case httpError
}

class SearchResultList: ObservableObject {
    @Published var searchHits = [searchHit]()
    @Published var endOfList = false
    var urlBase: String
    var pageStatus = PageStatus.ready(nextPage: 0)
    var cancellable: Set<AnyCancellable> = Set()
    static let ResultsPerPage = 15
    
    init(_ searchText: String, _ filterText: String) {
        var trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        trimmedSearch = trimmedSearch.replacingOccurrences(of: " ", with: "+")
        self.urlBase = "https://api.edamam.com/search?q=\(trimmedSearch)&app_id=a00eda9b&app_key=f5b053c4344b7ecc3ff4ce50677fe981\(filterText)"
        do{
            try searchRecipes()
            Analytics.logEvent(AnalyticsEventSearch, parameters: [
                AnalyticsParameterSearchTerm: trimmedSearch
             ])
        }catch{
            print("Error searching recipes \(error)")
        }
        
    }
    
    func searchRecipes() throws{
        guard case let .ready(page) = pageStatus else {
            return
        }
        
        pageStatus = .loading(page: page)
        
        print("Loading data from url: \(urlBase)\(getStringFromPage(page: page))")
        
        guard let url = URL(string: "\(urlBase)\(getStringFromPage(page: page))") else {
            throw SearchError.httpError
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let _ = output.response as? HTTPURLResponse else{
                    throw SearchError.httpError
                }
                return output.data
            }
            .decode(type: searchResult.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .tryFilter{
                if !$0.more {
                    throw SearchError.limitError
                }
                return true
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("done")
                    break
                case .failure(let error):
                    print("Error: \(error)")
                    self.endOfList = true
                    self.pageStatus = .done
                }
            }) { post in
                if post.hits.count == 0 {
                    self.pageStatus = .done
                }else{
                    self.pageStatus = .ready(nextPage: page + 1)
                    self.searchHits.append(contentsOf: post.hits)
                }
                
            }
            .store(in: &cancellable)
    }
    
    func getStringFromPage(page: Int) -> String {
        let from = Self.ResultsPerPage * page
        let to = Self.ResultsPerPage * (page + 1)
        return "&from=\(from)&to=\(to)"
    }
    
    func shouldLoad(searchHit: searchHit) -> Bool {
        if let lastID = searchHits.last?.id {
            if searchHit.id == lastID {
                return true
            } else {
                return false
            }
        }
        
        return false
    }
}
*/
