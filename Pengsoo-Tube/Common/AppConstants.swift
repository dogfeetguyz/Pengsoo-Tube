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
    static let partSnippet          : String = "playlistItems?part=snippet%2CcontentDetails"
    static let partBranding         : String = "channels?part=brandingSettings"
    
    static let keyApiKey            : String = "key"
    static let keyMaxResult         : String = "maxResults"
    static let keyPlaylistId        : String = "playlistId"
    static let keyBrandingId        : String = "id"
    static let keyPageToken         : String = "pageToken"
    
    static let valueApiKey          : String = Bundle.main.object(forInfoDictionaryKey: "GoogleSecretKey") as! String
    static let valueMaxResult       : Int = 50
    static let valuePlaylistGiantTV : String = "PLwGaGJBBtgFdm2f6aDXTxjgrRsj6D9eJ-"
    static let valuePlaylistYoutube : String = "PLwGaGJBBtgFfTN_ofhz-rdmeyStn5818M"
    static let valuePlaylistOutside : String = "PLwGaGJBBtgFedaczbgXOOppykqRkVZ787"
    static let valueBrandingId      : String = "UCtckgmUcpzqGnzcs7xEqMzQ"
    
    static let notification_show_miniplayer: NSNotification.Name = NSNotification.Name(rawValue: "notification_show_miniplayer")
    static let notification_play_quque: NSNotification.Name = NSNotification.Name(rawValue: "notification_play_quque")
    static let notification_update_player_dismiss_gesture: NSNotification.Name = NSNotification.Name(rawValue: "notification_update_player_dismiss_gesture")
    static let notification_userInfo_video_items: String = "notification_userInfo_video_items"
    static let notification_userInfo_playing_index: String = "notification_userInfo_playing_index"
    
    static let home_tab_titles = ["Youtube Only", "Giant Peng TV", "Collaboration"]
    static let home_tab_types = [RequestType.pengsooYoutube, RequestType.pengsooTv, RequestType.pengsooOutside]
    
    static let key_user_default_home_header_url : String = "user_default_home_header_url"
    static let key_user_default_autoplay : String = "user_default_autoplay"
    static let key_user_default_repeat_one : String = "user_default_repeat_one"
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
    case playlist
    case playlistCreate
    case playlistDelete
    case playlistUpdate
    case recent
    case recentDelete
    case playlistDetail
    case playlistDetailDelete
}
