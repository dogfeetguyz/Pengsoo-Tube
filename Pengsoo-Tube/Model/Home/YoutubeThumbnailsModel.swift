//
//  YoutubeThumbnailsModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct YoutubeThumbnailsModel {
    var small: YoutubeThumbnailModel = YoutubeThumbnailModel()
    var medium: YoutubeThumbnailModel = YoutubeThumbnailModel()
    var high: YoutubeThumbnailModel = YoutubeThumbnailModel()
}

extension YoutubeThumbnailsModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        small <- map["default"]
        medium <- map["medium"]
        high <- map["high"]
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
