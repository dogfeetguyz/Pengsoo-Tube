//
//  AppConstants.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation

struct AppConstants {
    
    static let baseUrl              : String = "https://www.googleapis.com/youtube/v3/"
    static let partSnippet          : String = "playlistItems?part=snippet"
    static let partBranding         : String = "channels?part=brandingSettings"
    
    static let keyApiKey            : String = "key"
    static let keyMaxResult         : String = "maxResults"
    static let keyPlaylistId        : String = "playlistId"
    static let keyBrandingId        : String = "id"
    static let keyPageToken         : String = "pageToken"
    
    static let valueApiKey          : String = Bundle.main.object(forInfoDictionaryKey: "GoogleSecretKey") as! String
    static let valueMaxResult       : Int = 50
    static let valuePlaylistGiantTV : String = "PLeq1C1537EvHO4nXCXb98stSy-AH8ojas"
    static let valuePlaylistYoutube : String = "PLeq1C1537EvH7jR04Gr5dUYf2wNTyXSg9"
    static let valuePlaylistOutside : String = "PLwGaGJBBtgFedaczbgXOOppykqRkVZ787"
    static let valueBrandingId      : String = "UCtckgmUcpzqGnzcs7xEqMzQ"
    
    static let notification_show_miniplayer: NSNotification.Name = NSNotification.Name(rawValue: "notification_show_miniplayer")
    static let notification_userInfo_currentPlayingItem: String = "currentPlayingItem"
    static let notification_userInfo_headerImgUrl: String = "headerImgUrl"
    
    static let home_tab_titles = ["Giant Peng TV", "Youtube Only", "Collaboration"]
    static let home_tab_types = [RequestType.pengsooTv, RequestType.pengsooYoutube, RequestType.pengsooOutside]
}

enum ViewModelDelegateError: Int {
    case noError = 0
    case networkError = 1
    case noItems = 2
    case fail = 3
}

enum RequestType: Int {
    case header = 0
    case pengsooTv
    case pengsooYoutube
    case pengsooOutside
    case mylist
    case mylistDelete
    case recentDetail
    case recentDetailDelete
    case mylistDetail
    case mylistDetailDelete
    
}

enum DragDirection {
    case Up
    case Down
}
