//
//  MypageDetailViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 25/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import CoreData
import UIKit

class LibraryDetailViewModel {
        
    var playlistItem: Playlist?
    var recentItems: [Recent]?
    weak var delegate: ViewModelDelegate?
    
    init(playlistItem: Playlist) {
        self.playlistItem = playlistItem
    }
    
    init(recentItems: [Recent]) {
        self.recentItems = recentItems
    }
    
    func deleteItem(at: Int) {
        if playlistItem != nil {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext
                playlistItem!.removeFromPlaylistVideos(at: at)
                do {
                    try managedOC.save()
                    delegate?.success(type: .playlistDetailDelete)
                } catch {
                    delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else if recentItems != nil {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext
                managedOC.delete(recentItems![at])
                recentItems?.remove(at: at)
                do {
                    try managedOC.save()
                    delegate?.success(type: .playlistDetailDelete)
                } catch {
                    delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        }
    }
    
    func moveItem(from: Int, to: Int) {
        guard playlistItem != nil else { return }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            
            let previouVideoItem = playlistItem!.playlistVideos![from] as! PlaylistVideo
            let entity = NSEntityDescription.entity(forEntityName: String(describing: PlaylistVideo.self ), in: managedOC)
            let newVideoItem = PlaylistVideo(entity: entity!, insertInto: managedOC)
            
            newVideoItem.publishedAt = previouVideoItem.publishedAt
            newVideoItem.thumbnailHigh = previouVideoItem.thumbnailHigh
            newVideoItem.thumbnailMedium = previouVideoItem.thumbnailMedium
            newVideoItem.thumbnailDefault = previouVideoItem.thumbnailDefault
            newVideoItem.videoTitle = previouVideoItem.videoTitle
            newVideoItem.videoDescription = previouVideoItem.videoDescription
            newVideoItem.videoId = previouVideoItem.videoId
            newVideoItem.inPlaylist = previouVideoItem.inPlaylist
            
            if from < to {
                playlistItem!.insertIntoPlaylistVideos(newVideoItem, at: to)
                playlistItem!.removeFromPlaylistVideos(at: from)
            } else {
                playlistItem!.removeFromPlaylistVideos(at: from)
                playlistItem!.insertIntoPlaylistVideos(newVideoItem, at: to)
            }
            
            do {
                try managedOC.save()
                delegate?.success(type: .playlistDetail)
            } catch {
                delegate?.showError(type: .playlistDetail, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .playlistDetail, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func deletePlaylist() {
        guard playlistItem != nil else { return }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            managedOC.delete(playlistItem!)
            playlistItem = nil
            do {
                try managedOC.save()
                delegate?.success(type: .playlistDelete)
            } catch {
                delegate?.showError(type: .playlistDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .playlistDelete, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func updatePlaylist(newTitle: String) {
        guard playlistItem != nil else { return }
        
        if newTitle.count == 0 {
            delegate?.showError(type: .playlistUpdate, error: .fail, message: "Please enter a name.")
            return
        } else {
            let libraryViewModel = LibraryViewModel()
            libraryViewModel.getPlaylist()
            for item in libraryViewModel.playlistItems {
                if item.title == newTitle {
                    delegate?.showError(type: .playlistUpdate, error: .fail, message: "The name you entered already exists.\nPlease enter another name.")
                    return
                }
            }
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext

                playlistItem!.updatedAt = Date()
                playlistItem!.title = newTitle
                
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
    }
}
