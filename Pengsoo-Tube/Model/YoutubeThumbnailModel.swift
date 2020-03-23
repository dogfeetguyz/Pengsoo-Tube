//
//  YoutubeThumbnailModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct YoutubeThumbnailModel {
    var url: String = ""
    var width: Int = 0
    var height: Int = 0
}

extension YoutubeThumbnailModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        url <- map["url"]
        width <- map["width"]
        height <- map["height"]
    }
}

/*
   "thumbnails": {
    "default": {
     "url": "https://i.ytimg.com/vi/2-pqvr566Vk/default.jpg",
     "width": 120,
     "height": 90
    },
    "medium": {
     "url": "https://i.ytimg.com/vi/2-pqvr566Vk/mqdefault.jpg",
     "width": 320,
     "height": 180
    },
    "high": {
     "url": "https://i.ytimg.com/vi/2-pqvr566Vk/hqdefault.jpg",
     "width": 480,
     "height": 360
    }
 */
