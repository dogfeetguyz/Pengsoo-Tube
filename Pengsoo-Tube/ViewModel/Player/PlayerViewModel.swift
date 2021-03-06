//
//  PlayerViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 31/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import CoreData
import UIKit

class PlayerViewModel: BaseViewModel {
    
    private var queueItems: [VideoItemModel] = []
    
    var playingIndex: Int = -1
    var canRequestMore: Bool = false
    var requestType: RequestType?
    var duration: Float = 0
    
    var isPaused: Bool = false
    var isEnded: Bool = false
    var isFullscreen: Bool = false
    
    func replaceQueue(videoItems: [VideoItemModel], playingIndex: Int, requestType: RequestType) {
        queueItems.removeAll()
        queueItems.append(contentsOf: videoItems)
        self.playingIndex = playingIndex
        self.requestType = requestType
        self.canRequestMore = (requestType == .pengsooTv || requestType == .pengsooYoutube || requestType == .pengsooOutside)
    }
    
    func getPlayingItem() -> VideoItemModel? {
        if playingIndex >= 0 && playingIndex <= queueItems.count-1 {
            return queueItems[playingIndex]
        } else {
            return nil
        }
    }
    
    func updateQueue(canRequestMore: Bool, videoItems: [VideoItemModel]? = nil) {
        if let items = videoItems {
            queueItems.removeAll()
            queueItems.append(contentsOf: items)
        }
        
        self.canRequestMore = canRequestMore
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
    
    func setDuration(duration: Double) {
        self.duration = Float(duration)
    }
    
    func getDuration() -> Float {
        return duration
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
                delegate?.showError(type: .recent, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .recent, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func checkLoadMoreQueue(checkPlayingIndex: Bool = true) {
        if canRequestMore {
            if !checkPlayingIndex || (checkPlayingIndex && (playingIndex == getQueueItems().count - 1)) {
                canRequestMore = false
                NotificationCenter.default.post(name: AppConstants.notification_load_more_queue, object: nil, userInfo: [AppConstants.notification_userInfo_request_type:requestType!])
            }
        }
    }
}
