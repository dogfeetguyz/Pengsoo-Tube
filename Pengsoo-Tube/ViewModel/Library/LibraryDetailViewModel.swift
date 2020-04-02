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
        
    var playItems: [VideoItemModel]
    var title: String
    weak var delegate: ViewModelDelegate?
    
    init(playItems: [VideoItemModel], title: String) {
        self.playItems = playItems
        self.title = title
    }
    
    func deleteItem(at: Int) {
        if title == "Recent" {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext
                let request: NSFetchRequest<Recent> = Recent.fetchRequest()
                request.predicate = NSPredicate(format: "videoId == %@", playItems[at].videoId)
                do {
                    let recentList = try managedOC.fetch(request)
                    managedOC.delete(recentList.first!)
                    do {
                        try managedOC.save()
                        playItems.remove(at: at)
                        delegate?.success(type: .playlistDetailDelete)
                    } catch {
                        delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                    }
                } catch {
                    delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext
                let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()
                request.predicate = NSPredicate(format: "title == %@", title)
                do {
                    let playlistItems = try managedOC.fetch(request)
                    let playlistItem = playlistItems.first!
                    playlistItem.removeFromPlaylistVideos(at: at)
                    do {
                        try managedOC.save()
                        playItems.remove(at: at)
                        delegate?.success(type: .playlistDetailDelete)
                    } catch {
                        delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                    }
                    
                } catch {
                    delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        }
    }
    
    func clearItems() {
        if title == "Recent" {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext
                let request: NSFetchRequest<Recent> = Recent.fetchRequest()
                do {
                    let recentList = try managedOC.fetch(request)
                    for item in recentList {
                        managedOC.delete(item)
                    }
                    do {
                        try managedOC.save()
                        playItems.removeAll()
                        delegate?.success(type: .playlistDetailDelete)
                    } catch {
                        delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                    }
                } catch {
                    delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext
                let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()
                request.predicate = NSPredicate(format: "title == %@", title)
                do {
                    let playlistItems = try managedOC.fetch(request)
                    playlistItems.first!.playlistVideos?.enumerateObjects({ (item, idx, _) in
                        managedOC.delete(item as! NSManagedObject)
                    })
                    
                    do {
                        try managedOC.save()
                        playItems.removeAll()
                        delegate?.success(type: .playlistDetailDelete)
                    } catch {
                        delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                    }
                    
                } catch {
                    delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistDetailDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        }
    }
    
    func moveItem(from: Int, to: Int) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()
            request.predicate = NSPredicate(format: "title == %@", title)
            do {
                let playlistItems = try managedOC.fetch(request)
                let playlistItem = playlistItems.first!
                
                
                let entity = NSEntityDescription.entity(forEntityName: String(describing: PlaylistVideo.self ), in: managedOC)
                let newVideoItem = PlaylistVideo(entity: entity!, insertInto: managedOC)
                
                let previouVideoItem = playItems[from]
                newVideoItem.publishedAt = previouVideoItem.publishedAt
                newVideoItem.thumbnailHigh = previouVideoItem.thumbnailHigh
                newVideoItem.thumbnailMedium = previouVideoItem.thumbnailMedium
                newVideoItem.thumbnailDefault = previouVideoItem.thumbnailDefault
                newVideoItem.videoTitle = previouVideoItem.videoTitle
                newVideoItem.videoDescription = previouVideoItem.videoDescription
                newVideoItem.videoId = previouVideoItem.videoId
                
                playlistItem.removeFromPlaylistVideos(at: from)
                playlistItem.insertIntoPlaylistVideos(newVideoItem, at: to)
                
                playItems = (playlistItem.playlistVideos!.array as! [PlaylistVideo]).map() {
                    return VideoItemModel(videoId: $0.videoId!, videoTitle: $0.videoTitle!, videoDescription: $0.videoDescription!, thumbnailDefault: $0.thumbnailDefault!, thumbnailMedium: $0.thumbnailMedium!, thumbnailHigh: $0.thumbnailHigh!, publishedAt: $0.publishedAt!)
                }
                
                do {
                    try managedOC.save()
                    delegate?.success(type: .playlistDetail)
                } catch {
                    delegate?.showError(type: .playlistDetail, error: .fail, message: "Something went wrong. Please try again.")
                }
                
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
            let request: NSFetchRequest<Playlist> = NSFetchRequest(entityName: String(describing: Playlist.self))
            request.predicate = NSPredicate(format: "title == %@", title)
            do {
                let playlistItems = try managedOC.fetch(request)
                
                if playlistItems.count > 0 {
                    let playlistItem = playlistItems.first!

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
            } catch {
                delegate?.showError(type: .playlistDelete, error: .fail, message: "Something went wrong. Please try again.")
            }

        } else {
            delegate?.showError(type: .playlistDelete, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func updatePlaylist(newTitle: String) {
        if newTitle.count == 0 {
            delegate?.showError(type: .playlistUpdate, error: .fail, message: "Please enter a new name.")
            return
        } else if newTitle == title {
            delegate?.showError(type: .playlistUpdate, error: .fail, message: "Please enter a new name.")
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
                let request: NSFetchRequest<Playlist> = NSFetchRequest(entityName: String(describing: Playlist.self))
                do {
                    var currentItem: Playlist?
                    let playlistItems = try managedOC.fetch(request)
                    for playlistItem in playlistItems {
                        if playlistItem.title == newTitle {
                            delegate?.showError(type: .playlistUpdate, error: .fail, message: "The name you entered already exists.\nPlease enter another name.")
                            return
                        } else if playlistItem.title == title {
                            currentItem = playlistItem
                        }
                    }
                    
                    if let playlistItem = currentItem {
                        playlistItem.updatedAt = Date()
                        playlistItem.title = newTitle
                        
                        do {
                            try managedOC.save()
                            title = newTitle
                            delegate?.success(type: .playlistUpdate)
                        } catch {
                            delegate?.showError(type: .playlistUpdate, error: .fail, message: "Something went wrong. Please try again.")
                        }
                    }
                } catch {
                    delegate?.showError(type: .playlistDelete, error: .fail, message: "Something went wrong. Please try again.")
                }
                
                
            } else {
                delegate?.showError(type: .playlistUpdate, error: .fail, message: "Something went wrong. Please try again.")
            }
        }
    }
}
