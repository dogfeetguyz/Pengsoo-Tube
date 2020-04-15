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

class HomeViewModel: BaseViewModel {
    
    var tvNextPageToken: String = ""
    var tvListItems: [VideoItemModel] = []
    
    var youtubeNextPageToken: String = ""
    var youtubeListItems: [VideoItemModel] = []
    
    var outsideNextPageToken: String = ""
    var outsideListItems: [VideoItemModel] = []
    
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
                            var videoItems: Array<VideoItemModel> = []
                            for item in youtubeListItem.items {
                                if item.snippet.title != "Private video" {
                                    let videoItem = VideoItemModel(videoId: item.snippet.resourceId.videoId,
                                                                   videoTitle: item.snippet.title,
                                                                   videoDescription: item.snippet.description,
                                                                   thumbnailDefault: item.snippet.thumbnails.small.url,
                                                                   thumbnailMedium: item.snippet.thumbnails.medium.url,
                                                                   thumbnailHigh: item.snippet.thumbnails.high.url,
                                                                   publishedAt: item.contentDetails.videoPublishedAt)
                                    
                                    if !videoItems.contains(videoItem) {
                                        videoItems.append(videoItem)
                                    }
                                }
                            }
                            
                            if type == .pengsooTv {
                                self.tvNextPageToken = youtubeListItem.nextPageToken
                                self.tvListItems.append(contentsOf: videoItems)
                            } else if type == .pengsooYoutube {
                                self.youtubeNextPageToken = youtubeListItem.nextPageToken
                                self.youtubeListItems.append(contentsOf: videoItems)
                            } else if type == .pengsooOutside {
                                self.outsideNextPageToken = youtubeListItem.nextPageToken
                                self.outsideListItems.append(contentsOf: videoItems)
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
    
    func getItemsList(for requestType: RequestType) -> [VideoItemModel]? {
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
    
    func getPlaylistItems() -> [PlaylistModel]? {
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

                let entity = NSEntityDescription.entity(forEntityName: String(describing: Playlist.self ), in: managedOC)
                let playlist = Playlist(entity: entity!, insertInto: managedOC)
                playlist.updatedAt = Date()
                playlist.title = title
                
                do {
                    try managedOC.save()
                    addToPlaylist(at: at, listOf: listOf, toPlaylist: playlist)
                } catch {
                    delegate?.showError(type: .playlistCreate, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistCreate, error: .fail, message: "Something went wrong. Please try again.")
            }
        }
    }
    
    func addToPlaylist(at: Int, listOf: RequestType, toPlaylist: Playlist) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: String(describing: PlaylistVideo.self ), in: managedOC)
            let playlistVideo = PlaylistVideo(entity: entity!, insertInto: managedOC)
            
            var youtubeItem: VideoItemModel?
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
            playlistVideo.publishedAt = youtubeItem!.publishedAt
            playlistVideo.thumbnailHigh = youtubeItem!.thumbnailHigh
            playlistVideo.thumbnailMedium = youtubeItem!.thumbnailMedium
            playlistVideo.thumbnailDefault = youtubeItem!.thumbnailDefault
            playlistVideo.videoTitle = youtubeItem!.videoTitle
            playlistVideo.videoDescription = youtubeItem!.videoDescription
            playlistVideo.videoId = youtubeItem!.videoId
            playlistVideo.inPlaylist = toPlaylist
            
            toPlaylist.addToPlaylistVideos(playlistVideo)
            toPlaylist.updatedAt = Date()
            do {
                try managedOC.save()
                delegate?.success(type: .playlistUpdate, message: "Added to \(toPlaylist.title!)")
            } catch {
                delegate?.showError(type: .playlistUpdate, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .playlistUpdate, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func addToPlaylist(at: Int, listOf: RequestType, toPlaylist: PlaylistModel) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<Playlist> = NSFetchRequest(entityName: String(describing: Playlist.self))
            request.predicate = NSPredicate(format: "title == %@", toPlaylist.title)
            
            do {
                let playlistItems = try managedOC.fetch(request)
                let playlistItem = playlistItems.first!
                addToPlaylist(at: at, listOf: listOf, toPlaylist: playlistItem)
            } catch {
                delegate?.showError(type: .playlistUpdate, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .playlistUpdate, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
}
