//
//  YoutubeContentDetails.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 4/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct YoutubeContentDetails {
    var videoPublishedAt: String = ""
}

extension YoutubeContentDetails: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        videoPublishedAt <- map["videoPublishedAt"]
    }
}
