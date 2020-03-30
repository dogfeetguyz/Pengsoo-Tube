//
//  brandingSettingsModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 24/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation
import ObjectMapper

struct BrandingSettingsModel {
    var image: HeaderImageModel = HeaderImageModel()
}

extension BrandingSettingsModel: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        image <- map["image"]
    }
}
