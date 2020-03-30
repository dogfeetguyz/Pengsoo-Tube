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
        
    var mylistItem: Mylist
    weak var delegate: ViewModelDelegate?
    
    init(mylistItem: Mylist) {
        self.mylistItem = mylistItem
    }
    
    func deleteItem(at: Int) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            mylistItem.removeFromVideos(at: at)
            do {
                try managedOC.save()
                delegate?.success(type: .mylistDetailDelete)
            } catch {
                delegate?.showError(type: .mylistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .mylistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func moveItem(from: Int, to: Int) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            
            let previouVideoItem = mylistItem.videos![from] as! MyVideo
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
                mylistItem.insertIntoVideos(newVideoItem, at: to)
                mylistItem.removeFromVideos(at: from)
            } else {
                mylistItem.removeFromVideos(at: from)
                mylistItem.insertIntoVideos(newVideoItem, at: to)
            }
            
            do {
                try managedOC.save()
                delegate?.success(type: .mylistDetail)
            } catch {
                delegate?.showError(type: .mylistDetail, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .mylistDetail, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func deleteMylist() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            managedOC.delete(mylistItem)
            
            do {
                try managedOC.save()
                delegate?.success(type: .mylistDelete)
            } catch {
                delegate?.showError(type: .mylistDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .mylistDelete, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
}
