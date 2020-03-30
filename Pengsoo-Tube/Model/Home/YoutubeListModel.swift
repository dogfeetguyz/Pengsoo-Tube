//
//  YoutubeListModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct YoutubeListModel {
    var nextPageToken: String = ""
    var items: Array<YoutubeItemModel> = Array()
}

extension YoutubeListModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        nextPageToken <- map["nextPageToken"]
        items <- map["items"]
    }
}

/*
 {
 "kind": "youtube#searchListResponse",
 "etag": "\"ksCrgYQhtFrXgbHAhi9Fo5t0C2I/V8-6hd3DhodrKIBT0NwUxUxfpkE\"",
 "nextPageToken": "CBkQAA",
 "regionCode": "AU",
 "pageInfo": {
  "totalResults": 284,
  "resultsPerPage": 25
 },
 "items": [
  {
   "kind": "youtube#searchResult",
   "etag": "\"ksCrgYQhtFrXgbHAhi9Fo5t0C2I/JZDfDWjREmt-gFxMm-UOGhKrpW0\"",
   "id": {
    "kind": "youtube#video",
    "videoId": "2-pqvr566Vk"
   },
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
   }
  }
 */
