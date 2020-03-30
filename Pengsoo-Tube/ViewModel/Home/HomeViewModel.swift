//
//  HomeViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import CoreData
import UIKit

class HomeViewModel {
    
    var tvNextPageToken: String = ""
    var tvListItems: [YoutubeItemModel] = []
    
    var youtubeNextPageToken: String = ""
    var youtubeListItems: [YoutubeItemModel] = []
    
    var outsideNextPageToken: String = ""
    var outsideListItems: [YoutubeItemModel] = []
    
    var headerUrl: String = ""
    
    weak var delegate: ViewModelDelegate?
    
    func dispatchPengsooList(type: RequestType) {
        dispatchPengsooList(type:type, isInitial: true)
    }
    
    func dispatchPengsooList(type: RequestType, isInitial: Bool) {
        
        if checkNetwork() {
            var parameters: Parameters = Parameters()
            if isInitial {
                if type == .pengsooTv {
                    tvNextPageToken = ""
                    tvListItems.removeAll()
                } else if type == .pengsooYoutube {
                    youtubeNextPageToken = ""
                    youtubeListItems.removeAll()
                } else if type == .pengsooOutside {
                    outsideNextPageToken = ""
                    outsideListItems.removeAll()
                }
            } else {
                if type == .pengsooTv && tvNextPageToken.count > 0 {
                    parameters[AppConstants.keyPageToken] = tvNextPageToken
                } else if type == .pengsooYoutube && youtubeNextPageToken.count > 0 {
                    parameters[AppConstants.keyPageToken] = youtubeNextPageToken
                } else if type == .pengsooOutside && outsideNextPageToken.count > 0 {
                    parameters[AppConstants.keyPageToken] = outsideNextPageToken
                } else {
                    self.delegate?.showError(type:type, error: .noItems)
                    return
                }
            }
            
            if type == .pengsooTv {
                parameters[AppConstants.keyPlaylistId] = AppConstants.valuePlaylistGiantTV
            } else if type == .pengsooYoutube {
                parameters[AppConstants.keyPlaylistId] = AppConstants.valuePlaylistYoutube
            } else if type == .pengsooOutside {
                parameters[AppConstants.keyPlaylistId] = AppConstants.valuePlaylistOutside
            }
            
            parameters[AppConstants.keyMaxResult] = AppConstants.valueMaxResult
            parameters[AppConstants.keyApiKey] = AppConstants.valueApiKey
            
            AF.request(AppConstants.baseUrl + AppConstants.partSnippet, method: .get, parameters: parameters)
                .validate()
                .responseObject(completionHandler: { (response: AFDataResponse<YoutubeListModel>) in
                    switch response.result {
                    case .success(let youtubeListItem):
                        if youtubeListItem.items.count == 0 {
                            if type == .pengsooTv {
                                self.tvNextPageToken = ""
                            } else if type == .pengsooYoutube {
                                self.youtubeNextPageToken = ""
                            } else if type == .pengsooOutside {
                                self.outsideNextPageToken = ""
                            }
                            self.delegate?.showError(type:type, error: .noItems)
                        } else {
                            var items: Array<YoutubeItemModel> = []
                            for item in youtubeListItem.items {
                                if item.snippet.title != "Private video" {
                                    if !items.contains(item) {
                                        items.append(item)
                                    }
                                }
                            }
                            
                            if type == .pengsooTv {
                                self.tvNextPageToken = youtubeListItem.nextPageToken
                                self.tvListItems.append(contentsOf: items)
                            } else if type == .pengsooYoutube {
                                self.youtubeNextPageToken = youtubeListItem.nextPageToken
                                self.youtubeListItems.append(contentsOf: items)
                            } else if type == .pengsooOutside {
                                self.outsideNextPageToken = youtubeListItem.nextPageToken
                                self.outsideListItems.append(contentsOf: items)
                            }
                            self.delegate?.success(type:type)
                        }
                    case .failure(let error):
                        print(error)
                        self.delegate?.showError(type:type, error: .networkError)
                    }
                })
        } else {
            self.delegate?.showError(type:type, error: .networkError)
        }
    }
    
    func getHeaderInfo() {
        if checkNetwork() {
            var parameters: Parameters = Parameters()
            parameters[AppConstants.keyBrandingId] = AppConstants.valueBrandingId
            parameters[AppConstants.keyApiKey] = AppConstants.valueApiKey
            
            AF.request(AppConstants.baseUrl + AppConstants.partBranding, method: .get, parameters: parameters)
                .validate()
                .responseObject(completionHandler: { (response: AFDataResponse<YoutubeListModel>) in
                    switch response.result {
                    case .success(let youtubeListItem):
                        if youtubeListItem.items.count == 0 {
                            self.delegate?.showError(type:.header, error: .noItems)
                        } else {
                            if youtubeListItem.items[0].brandingSettings.image.bannerMobileHdImageUrl.count > 0 {
                                self.headerUrl = youtubeListItem.items[0].brandingSettings.image.bannerMobileHdImageUrl
                            } else if youtubeListItem.items[0].brandingSettings.image.bannerMobileMediumHdImageUrl.count > 0 {
                                self.headerUrl = youtubeListItem.items[0].brandingSettings.image.bannerMobileMediumHdImageUrl
                            } else if youtubeListItem.items[0].brandingSettings.image.bannerMobileLowImageUrl.count > 0 {
                                self.headerUrl = youtubeListItem.items[0].brandingSettings.image.bannerMobileLowImageUrl
                            } else if youtubeListItem.items[0].brandingSettings.image.bannerMobileImageUrl.count > 0 {
                                self.headerUrl = youtubeListItem.items[0].brandingSettings.image.bannerMobileImageUrl
                            } else {
                                self.delegate?.showError(type:.header, error: .noItems)
                                return
                            }
                            self.delegate?.success(type: .header)
                        }
                    case .failure(let error):
                        print(error)
                        self.delegate?.showError(type:.header, error: .networkError)
                    }
                })
        } else {
            self.delegate?.showError(type:.header, error: .networkError)
        }
    }
    
    func getItemsList(for requestType: RequestType) -> [YoutubeItemModel]? {
        switch requestType {
        case .pengsooTv:
            return tvListItems
        case .pengsooYoutube:
            return youtubeListItems
        case .pengsooOutside:
            return outsideListItems
        default:
            return nil
        }
    }
    
    func getPlaylistItems() -> [Mylist]? {
        let libraryViewModel = LibraryViewModel()
        libraryViewModel.getPlaylist()
        
        return libraryViewModel.playlistItems
    }
    
    func addtoNewPlaylist(title: String, at: Int, listOf: RequestType) {
        
        if title.count == 0 {
            delegate?.showError(type: .playlistCreate, error: .fail, message: "Please enter a name.")
            return
        } else {

            let libraryViewModel = LibraryViewModel()
            libraryViewModel.getPlaylist()
            
            for playlist in libraryViewModel.playlistItems {
                if playlist.title == title {
                    delegate?.showError(type: .playlistCreate, error: .fail, message: "The name you entered already exists.\nPlease enter another name.")
                    return
                }
            }

            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext

                let entity = NSEntityDescription.entity(forEntityName: String(describing: Mylist.self ), in: managedOC)
                let playlist = Mylist(entity: entity!, insertInto: managedOC)
                playlist.updatedAt = Date()
                playlist.title = title
                
                do {
                    try managedOC.save()
                    libraryViewModel.playlistItems.append(playlist)
                    addToPlaylist(at: at, listOf: listOf, toPlaylist: playlist)
                } catch {
                    delegate?.showError(type: .playlistCreate, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistCreate, error: .fail, message: "Something went wrong. Please try again.")
            }
        }
    }
    
    func addToPlaylist(at: Int, listOf: RequestType, toPlaylist: Mylist) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: String(describing: MyVideo.self ), in: managedOC)
            let myVideo = MyVideo(entity: entity!, insertInto: managedOC)
            
            var youtubeItem: YoutubeItemModel?
            if listOf == .pengsooTv {
                youtubeItem = tvListItems[at]
            } else if listOf == .pengsooYoutube {
                youtubeItem = youtubeListItems[at]
            } else if listOf == .pengsooOutside {
                youtubeItem = outsideListItems[at]
            } else {
                delegate?.showError(type: .playlistUpdate, error: .fail, message: "Something went wrong. Please try again.")
                return
            }
            myVideo.channelTitle = youtubeItem!.snippet.channelTitle
            myVideo.publishedAt = youtubeItem!.snippet.publishedAt
            myVideo.thumbnailHigh = youtubeItem!.snippet.thumbnails.high.url
            myVideo.thumbnailMedium = youtubeItem!.snippet.thumbnails.medium.url
            myVideo.thumbnailDefault = youtubeItem!.snippet.thumbnails.small.url
            myVideo.videoTitle = youtubeItem!.snippet.title
            myVideo.videoDescription = youtubeItem!.snippet.description
            myVideo.videoId = youtubeItem!.snippet.resourceId.videoId
            myVideo.inPlaylist = toPlaylist
            
            toPlaylist.addToVideos(myVideo)
            do {
                try managedOC.save()
                delegate?.success(type: .playlistUpdate)
            } catch {
                delegate?.showError(type: .playlistUpdate, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .playlistUpdate, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func checkNetwork() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
