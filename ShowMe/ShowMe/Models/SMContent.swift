//
//  SMContent.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 11/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit
import ObjectMapper

class SMContent: Mappable {
    
    var title: String?
    var poster: String?
    var year: String?
    var imdbID: String?
    
    
    // MARK: - Initializer method
    
    required init?(map: Map) {
        // Do nothing
    }
    
     
    // MARK: - Mapping method
    
    func mapping(map: Map) {
        title <- map["Title"]
        poster <- map["Poster"]
        year <- map["Year"]
        imdbID <- map["imdbID"]
    }
    
}
