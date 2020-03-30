//
//  YoutubeItemModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct YoutubeSnippetModel {
    var publishedAt: String = ""
    var title: String = ""
    var description: String = ""
    var channelTitle: String = ""
    var liveBroadcastContent: String = ""
    var thumbnails: YoutubeThumbnailsModel = YoutubeThumbnailsModel()
    var resourceId: YoutubeVideoIdModel = YoutubeVideoIdModel()
}

extension YoutubeSnippetModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        publishedAt <- map["publishedAt"]
        title <- map["title"]
        description <- map["description"]
        channelTitle <- map["channelTitle"]
        liveBroadcastContent <- map["liveBroadcastContent"]
        thumbnails <- map["thumbnails"]
        resourceId <- map["resourceId"]
    }
}

/*
  "snippet": {
   "publishedAt": "2020-03-20T09:00:05.000Z",
   "channelId": "UCtckgmUcpzqGnzcs7xEqMzQ",
   "title": "[미방송분] 펭TV에서 못다 한 이야기 대방출! (feat. 컬링펭수, 화훼펭수) | ENG CC",
   "description": "펭-하! 그동안 제작진 외장하드에 쌓여있던 미방송분 대방출합니당 (23일, 27일도 기대해주세용!)",
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
   },
   "channelTitle": "자이언트 펭TV",
   "liveBroadcastContent": "none"
   "resourceId": {
    "kind": "youtube#video",
    "videoId": "eLJ_mmyj_XI"
   }
  }
 */
