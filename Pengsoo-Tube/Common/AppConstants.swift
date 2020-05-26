//
//  AppConstants.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

struct AppConstants {
    
    static let baseUrl              : String = "https://www.googleapis.com/youtube/v3/"
    static let partSnippet          : String = "playlistItems?part=snippet%2CcontentDetails"
    static let partBranding         : String = "channels?part=brandingSettings"
    
    static let keyApiKey            : String = "key"
    static let keyMaxResult         : String = "maxResults"
    static let keyPlaylistId        : String = "playlistId"
    static let keyBrandingId        : String = "id"
    static let keyPageToken         : String = "pageToken"
    
    static let valueApiKey          : String = "AIzaSyBompOLCe0ujNkYPELVHg5JzqlXadzAG5I"
    static let valueMaxResult       : Int = 50
    static let valuePlaylistGiantTV : String = "PLwGaGJBBtgFdm2f6aDXTxjgrRsj6D9eJ-"
    static let valuePlaylistYoutube : String = "PLwGaGJBBtgFfTN_ofhz-rdmeyStn5818M"
    static let valuePlaylistOutside : String = "PLwGaGJBBtgFedaczbgXOOppykqRkVZ787"
    static let valueBrandingId      : String = "UCtckgmUcpzqGnzcs7xEqMzQ"
    
    static let memeAlbumName: String = "PENG-HA Tube"
    
    static let notification_show_miniplayer: NSNotification.Name = NSNotification.Name(rawValue: "notification_show_miniplayer")
    static let notification_reload_meme: NSNotification.Name = NSNotification.Name(rawValue: "notification_reload_meme")
    static let notification_play_quque: NSNotification.Name = NSNotification.Name(rawValue: "notification_play_quque")
    static let notification_load_more_queue: NSNotification.Name = NSNotification.Name(rawValue: "notification_load_more_queue")
    static let notification_add_to_queue: NSNotification.Name = NSNotification.Name(rawValue: "notification_add_to_queue")
    static let notification_update_player_dismiss_gesture: NSNotification.Name = NSNotification.Name(rawValue: "notification_update_player_dismiss_gesture")
    static let notification_userInfo_video_items: String = "notification_userInfo_video_items"
    static let notification_userInfo_playing_index: String = "notification_userInfo_playing_index"
    static let notification_userInfo_request_type: String = "notification_userInfo_request_type"
    static let notification_userInfo_can_request_more: String = "notification_userInfo_can_request_more"
    
    static let home_tab_titles = ["Youtube Only", "Giant Peng TV", "Collaboration"]
    static let home_tab_types = [RequestType.pengsooYoutube, RequestType.pengsooTv, RequestType.pengsooOutside]
    
    static let key_user_default_home_header_url : String = "user_default_home_header_url"
    static let key_user_default_autoplay : String = "user_default_autoplay"
    static let key_user_default_repeat_one : String = "user_default_repeat_one"
    
    static let text_colors = [ UIColor(red: 0, green: 0, blue: 0, alpha: 0),
                                UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                                UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1),
                                UIColor(red: 0, green: 0, blue: 0, alpha: 1),
                                UIColor(red: 255/255, green: 38/255, blue: 0/255, alpha: 1),
                                UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1),
                                UIColor(red: 255/255, green: 251/255, blue: 0/255, alpha: 1),
                                UIColor(red: 142/255, green: 250/255, blue: 0/255, alpha: 1),
                                UIColor(red: 0/255, green: 249/255, blue: 0/255, alpha: 1),
                                UIColor(red: 0/255, green: 250/255, blue: 146/255, alpha: 1),
                                UIColor(red: 0/255, green: 253/255, blue: 255/255, alpha: 1),
                                UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1),
                                UIColor(red: 4/255, green: 51/255, blue: 255/255, alpha: 1),
                                UIColor(red: 148/255, green: 55/255, blue: 255/255, alpha: 1),
                                UIColor(red: 255/255, green: 64/255, blue: 255/255, alpha: 1),
                                UIColor(red: 255/255, green: 47/255, blue: 146/255, alpha: 1)]

    static let border_colors = [ UIColor(red: 0, green: 0, blue: 0, alpha: 0),
                                UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                                UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1),
                                UIColor(red: 0, green: 0, blue: 0, alpha: 1),
                                UIColor(red: 255/255, green: 38/255, blue: 0/255, alpha: 1),
                                UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1),
                                UIColor(red: 255/255, green: 251/255, blue: 0/255, alpha: 1),
                                UIColor(red: 142/255, green: 250/255, blue: 0/255, alpha: 1),
                                UIColor(red: 0/255, green: 249/255, blue: 0/255, alpha: 1),
                                UIColor(red: 0/255, green: 250/255, blue: 146/255, alpha: 1),
                                UIColor(red: 0/255, green: 253/255, blue: 255/255, alpha: 1),
                                UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1),
                                UIColor(red: 4/255, green: 51/255, blue: 255/255, alpha: 1),
                                UIColor(red: 148/255, green: 55/255, blue: 255/255, alpha: 1),
                                UIColor(red: 255/255, green: 64/255, blue: 255/255, alpha: 1),
                                UIColor(red: 255/255, green: 47/255, blue: 146/255, alpha: 1)]
    

    static let bg_colors = [ UIColor(red: 0, green: 0, blue: 0, alpha: 0),
                                UIColor(red: 1, green: 1, blue: 1, alpha: 0.7),
                                UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.7),
                                UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 0.7),
                                UIColor(red: 0, green: 0, blue: 0, alpha: 0.7),
                                UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 0.7),
                                UIColor(red: 255/255, green: 212/255, blue: 121/255, alpha: 0.7),
                                UIColor(red: 255/255, green: 252/255, blue: 121/255, alpha: 0.7),
                                UIColor(red: 212/255, green: 251/255, blue: 121/255, alpha: 0.7),
                                UIColor(red: 115/255, green: 250/255, blue: 121/255, alpha: 0.7),
                                UIColor(red: 115/255, green: 252/255, blue: 214/255, alpha: 0.7),
                                UIColor(red: 115/255, green: 253/255, blue: 255/255, alpha: 0.7),
                                UIColor(red: 118/255, green: 214/255, blue: 255/255, alpha: 0.7),
                                UIColor(red: 122/255, green: 129/255, blue: 255/255, alpha: 0.7),
                                UIColor(red: 215/255, green: 131/255, blue: 255/255, alpha: 0.7),
                                UIColor(red: 255/255, green: 133/255, blue: 255/255, alpha: 0.7),
                                UIColor(red: 255/255, green: 138/255, blue: 216/255, alpha: 0.7)]
    
//
//    static let bg_colors = [ UIColor(red: 0, green: 0, blue: 0, alpha: 0),
//                                UIColor(red: 1, green: 1, blue: 1, alpha: 0.5),
//                                UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.5),
//                                UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 0.5),
//                                UIColor(red: 0, green: 0, blue: 0, alpha: 0.5),
//                                UIColor(red: 255/255, green: 38/255, blue: 0/255, alpha: 0.5),
//                                UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 0.5),
//                                UIColor(red: 255/255, green: 251/255, blue: 0/255, alpha: 0.5),
//                                UIColor(red: 142/255, green: 250/255, blue: 0/255, alpha: 0.5),
//                                UIColor(red: 0/255, green: 249/255, blue: 0/255, alpha: 0.5),
//                                UIColor(red: 0/255, green: 250/255, blue: 146/255, alpha: 0.5),
//                                UIColor(red: 0/255, green: 253/255, blue: 255/255, alpha: 0.5),
//                                UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 0.5),
//                                UIColor(red: 4/255, green: 51/255, blue: 255/255, alpha: 0.5),
//                                UIColor(red: 148/255, green: 55/255, blue: 255/255, alpha: 0.5),
//                                UIColor(red: 255/255, green: 64/255, blue: 255/255, alpha: 0.5),
//                                UIColor(red: 255/255, green: 47/255, blue: 146/255, alpha: 0.5)]
    
    static let shadow_colors = [ UIColor(red: 0, green: 0, blue: 0, alpha: 0),
                                 UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)]
}

enum ViewModelDelegateError: Int {
    case noError = 0
    case networkError = 1
    case noItems = 2
    case fail = 3
}

enum RequestType: Int {
    case header = 0
    case pengsooTv = 1
    case pengsooYoutube = 2
    case pengsooOutside = 3
    case playlist = 4
    case playlistCreate = 5
    case playlistDelete = 6
    case playlistUpdate = 7
    case recent = 8
    case recentDelete = 9
    case playlistDetail = 10
    case playlistDetailDelete = 11
    case memeCheckAuthorization = 12
    case memeCreateAlbum = 13
    case memeSave = 14
    case memePhotos = 15
    case memeDelete = 16
}
