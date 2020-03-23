//
//  AppConstants.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation

struct AppConstants {
    
    static let baseUrl          : String = "https://www.googleapis.com/youtube/v3/search?part=snippet"
    
    static let keyApiKey        : String = "key"
    static let keyMaxResult     : String = "maxResults"
    static let keyOrder         : String = "order"
    static let keyType          : String = "type"
    static let keyChannelId     : String = "channelId"
    static let keyKeyword       : String = "q"
    static let keyPageToken     : String = "pageToken"
    
    static let valueApiKey      : String = Bundle.main.object(forInfoDictionaryKey: "GoogleSecretKey") as! String
    static let valueMaxResult   : Int = 50
    static let valueOrder       : String = "date"
    static let valueType        : String = "video"
    static let valueChannelId   : String = "UCtckgmUcpzqGnzcs7xEqMzQ"
    static let valueKeyword     : String = "펭수"
}

public enum ViewModelDelegateError: Int {
    /// Use kilogram for a routine
    case networkError = 0
    
    /// Use pound for a routine
    case noItems = 1
}
