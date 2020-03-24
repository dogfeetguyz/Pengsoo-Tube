//
//  YoutubeItemModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct YoutubeItemModel {
    var id: YoutubeVideoIdModel = YoutubeVideoIdModel()
    var snippet: YoutubeSnippetModel = YoutubeSnippetModel()
    var brandingSettings: BrandingSettingsModel = BrandingSettingsModel()
}

extension YoutubeItemModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        snippet <- map["snippet"]
        brandingSettings <- map["brandingSettings"]
    }
}

/*
 "kind": "youtube#searchResult",
 "etag": "\"ksCrgYQhtFrXgbHAhi9Fo5t0C2I/JZDfDWjREmt-gFxMm-UOGhKrpW0\"",
 "id": {
  "kind": "youtube#video",
  "videoId": "2-pqvr566Vk"
 },
 "snippet": {
 }
 */
