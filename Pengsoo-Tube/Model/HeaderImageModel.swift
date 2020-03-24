//
//  HeaderImageModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 24/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct HeaderImageModel {
    var bannerMobileImageUrl: String = ""
    var bannerMobileLowImageUrl: String = ""
    var bannerMobileMediumHdImageUrl: String = ""
    var bannerMobileHdImageUrl: String = ""
}

extension HeaderImageModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        bannerMobileImageUrl <- map["bannerMobileImageUrl"]
        bannerMobileLowImageUrl <- map["bannerMobileLowImageUrl"]
        bannerMobileMediumHdImageUrl <- map["bannerMobileMediumHdImageUrl"]
        bannerMobileHdImageUrl <- map["bannerMobileHdImageUrl"]
    }
}
