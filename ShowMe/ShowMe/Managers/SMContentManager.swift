//
//  SMContentManager.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 11/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

enum SMContentType: String {
    case Movie = "movie"
    case Show = "show"
    
    func apiString() -> String {
        switch self {
        case .Movie:
            return "movie"
        case .Show:
            return "series"
        }
    }
}


class SMContentManager: NSObject {
    
    static let shared = SMContentManager()
    var contents: [SMContent]?
    private var searchRequest: Request?
    var totalResults: String?
    var currentPage: Int = 0
    private var lastSearchedString: String?

    // Private initializer
    private override init() {}
    
    // MARK: Custom methods
    
    /**Fetch contents from server for given search text*/
    func fetchContents(for searchText: String?, type: SMContentType = .Movie, page: Int, successBlock: @escaping (_ withResponse: DataResponse<Any>?, _ successStatus: Bool?) -> Void, failureBlock: @escaping (_ withError: DataResponse<Any>?, _ cancelStatus: Bool) -> Void) {
        if let text = searchText {
            var urlString = "http://www.omdbapi.com/?apikey=fecbae1d&s=\(text)&type=\(type.apiString())&page=\(page)"
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! // Hanlding spaces/special characters in request url.
            if let url = URL(string: urlString) {
                currentPage = page
                cancelOnGoingRequest()
                
                searchRequest = SMNetworkManager.getRequestWithSucceccBlock(url: url, parameter: nil, successblock: { [weak self] (response, status) in
                    
                    self?.resetSearchRequest()
                    if let responseJSON = response?.result.value as? [String: Any], let contentsJSON = responseJSON["Search"] as? [[String: Any]] {
                        SMContentManager.shared.totalResults = responseJSON["totalResults"] as? String
                        if SMContentManager.shared.contents == nil {
                            SMContentManager.shared.contents = []
                        }
                        let contents = Mapper<SMContent>().mapArray(JSONArray: contentsJSON)
                        if self?.lastSearchedString == text { // For same search text. Probably for refresh or pagination.
                            SMContentManager.shared.contents! += contents
                        } else { // New search text
                            SMContentManager.shared.contents! = contents
                        }
                        self?.removeDuplicates()
                        SMContentManager.shared.lastSearchedString = text
                        successBlock(response, status)
                    } else {
                        SMContentManager.shared.lastSearchedString = text
                        failureBlock(response, false)
                    }
                    
                }) { [weak self] (response, cancelStatus) in
                    
                    SMContentManager.shared.lastSearchedString = text
                    self?.resetSearchRequest()
                    failureBlock(response, cancelStatus)
                    
                }
            }
        }
    }
    
    /**Cancel ongoing request*/
    func cancelOnGoingRequest() {
        searchRequest?.cancel()
        resetSearchRequest()
    }
    
    /**Reset current content fetching request*/
    func resetSearchRequest() {
        searchRequest = nil
    }
    
    /**Remove duplicate records*/
    func removeDuplicates() {
        var uniqueContents: [SMContent] = []
        if let contents = SMContentManager.shared.contents {
            for content in contents {
                let isContains = uniqueContents.contains {( $0.imdbID == content.imdbID )}
                if !isContains {
                    uniqueContents.append(content)
                }
            }
        }
        SMContentManager.shared.contents = uniqueContents
    }
    
    /**Clears all data in shared manager.*/
    func clearAll() {
        cancelOnGoingRequest()
        SMContentManager.shared.contents = nil
        SMContentManager.shared.totalResults = nil
        SMContentManager.shared.currentPage = 0
        SMContentManager.shared.lastSearchedString = nil
    }
    
}
