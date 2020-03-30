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
    var snippet: YoutubeSnippetModel = YoutubeSnippetModel()
    var brandingSettings: BrandingSettingsModel = BrandingSettingsModel()
}

extension YoutubeItemModel: Equatable {
    static func == (lhs: YoutubeItemModel, rhs: YoutubeItemModel) -> Bool {
        return lhs.snippet.resourceId.videoId == rhs.snippet.resourceId.videoId
    }
}

extension YoutubeItemModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        snippet <- map["snippet"]
        brandingSettings <- map["brandingSettings"]
    }
}

/*
 "kind": "youtube#searchResult",
 "etag": "\"ksCrgYQhtFrXgbHAhi9Fo5t0C2I/JZDfDWjREmt-gFxMm-UOGhKrpW0\"",
 "snippet": {
 }
 */
