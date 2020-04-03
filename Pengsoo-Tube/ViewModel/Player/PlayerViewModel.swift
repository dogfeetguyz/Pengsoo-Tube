//
//  PlayerViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 31/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import CoreData
import UIKit

class PlayerViewModel {
    
    weak var delegate: ViewModelDelegate?
    private var queueItems: [VideoItemModel] = []
    private var playingIndex: Int = -1
    
    func replaceQueue(videoItems: [VideoItemModel], playingIndex: Int) {
        queueItems.removeAll()
        queueItems.append(contentsOf: videoItems)
        self.playingIndex = playingIndex
    }
    
    func updatePlayerUI() {
        
    }
    
    func getPlayingItem() -> VideoItemModel? {
        if playingIndex >= 0 && playingIndex <= queueItems.count-1 {
            return queueItems[playingIndex]
        } else {
            return nil
        }
    }
    
    func getQueueItems() -> [VideoItemModel] {
        return queueItems
    }
    
    func getPlayingIndex() -> Int {
        return playingIndex
    }
    
    func setPlayingIndex(index: Int) {
        playingIndex = index
    }
    
    func addToRecent(item: VideoItemModel) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            
            do {
                let request: NSFetchRequest<Recent> = NSFetchRequest(entityName: String(describing: Recent.self))
                let fetchedList = try managedOC.fetch(request)
                if fetchedList.count > 0 {
                    for fetchedItem in fetchedList {
                        if fetchedItem.videoId == item.videoId {
                            managedOC.delete(fetchedItem)
                            break
                        }
                    }
                }
            } catch {
            }

            let entity = NSEntityDescription.entity(forEntityName: String(describing: Recent.self ), in: managedOC)
            let recent = Recent(entity: entity!, insertInto: managedOC)
            
            recent.publishedAt = item.publishedAt
            recent.thumbnailHigh = item.thumbnailHigh
            recent.thumbnailMedium = item.thumbnailMedium
            recent.thumbnailDefault = item.thumbnailDefault
            recent.videoTitle = item.videoTitle
            recent.videoDescription = item.videoDescription
            recent.videoId = item.videoId
            
            do {
                try managedOC.save()
                delegate?.success(type: .recent)
            } catch {
                delegate?.showError(type: .recent, error: .fail)
            }
        } else {
            delegate?.showError(type: .recent, error: .fail)
        }
    }
}
