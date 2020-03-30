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
        
    var playlistItem: Mylist
    weak var delegate: ViewModelDelegate?
    
    init(playlistItem: Mylist) {
        self.playlistItem = playlistItem
    }
    
    func deleteItem(at: Int) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            playlistItem.removeFromVideos(at: at)
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
    
    func moveItem(from: Int, to: Int) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            
            let previouVideoItem = playlistItem.videos![from] as! MyVideo
            let entity = NSEntityDescription.entity(forEntityName: String(describing: MyVideo.self ), in: managedOC)
            let newVideoItem = MyVideo(entity: entity!, insertInto: managedOC)
            newVideoItem.channelTitle = previouVideoItem.channelTitle
            newVideoItem.publishedAt = previouVideoItem.publishedAt
            newVideoItem.thumbnailHigh = previouVideoItem.thumbnailHigh
            newVideoItem.thumbnailMedium = previouVideoItem.thumbnailMedium
            newVideoItem.thumbnailDefault = previouVideoItem.thumbnailDefault
            newVideoItem.videoTitle = previouVideoItem.videoTitle
            newVideoItem.videoDescription = previouVideoItem.videoDescription
            newVideoItem.videoId = previouVideoItem.videoId
            newVideoItem.inPlaylist = previouVideoItem.inPlaylist
            
            if from < to {
                playlistItem.insertIntoVideos(newVideoItem, at: to)
                playlistItem.removeFromVideos(at: from)
            } else {
                playlistItem.removeFromVideos(at: from)
                playlistItem.insertIntoVideos(newVideoItem, at: to)
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
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            managedOC.delete(playlistItem)
            
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
}
