//
//  YoutubeVideoIdModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct YoutubeVideoIdModel {
    var videoId: String = ""
}

extension YoutubeVideoIdModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        videoId <- map["videoId"]
    }
}

/*
 "resourceId": {
  "kind": "youtube#video",
  "videoId": "2-pqvr566Vk"
 },
 */
