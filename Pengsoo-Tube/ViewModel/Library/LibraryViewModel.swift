//
//  MypageViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 24/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import CoreData
import UIKit

class LibraryViewModel {
    
    var recentItems: [PlayItemModel] = []
    var playlistItems: [PlaylistModel] = []
    weak var delegate: ViewModelDelegate?
        
    func getRecent() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<Recent> = NSFetchRequest(entityName: String(describing: Recent.self))
            
            do {
                let fetchedList = try managedOC.fetch(request)
                recentItems = fetchedList.reversed().map() {
                    return PlayItemModel(videoId: $0.videoId!, videoTitle: $0.videoTitle!, videoDescription: $0.videoDescription!, thumbnailDefault: $0.thumbnailDefault!, thumbnailMedium: $0.thumbnailMedium!, thumbnailHigh: $0.thumbnailHigh!, publishedAt: $0.publishedAt!)
                }
                
                if fetchedList.count > 0 {
                    delegate?.success(type: .recent)
                } else {
                    delegate?.showError(type: .recent, error: .noItems)
                }
            } catch {
                delegate?.showError(type: .recent, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .recent, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func getPlaylist() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<Playlist> = NSFetchRequest(entityName: String(describing: Playlist.self))
            request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            
            do {
                let fetchedList = try managedOC.fetch(request)
                playlistItems = fetchedList.map() {
                    return PlaylistModel(title: $0.title!, videos: $0.playlistVideos!.array as! [PlaylistVideo])
                }
                
                if fetchedList.count > 0 {
                    delegate?.success(type: .playlist)
                } else {
                    delegate?.showError(type: .playlist, error: .noItems)
                }
            } catch {
                delegate?.showError(type: .playlist, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .playlist, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func createPlaylist(title: String) {
        if title.count == 0 {
            delegate?.showError(type: .playlistCreate, error: .fail, message: "Please enter a name.")
            return
        } else {
            for playlist in playlistItems {
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
                    playlistItems.insert(PlaylistModel(title: playlist.title!, videos: playlist.playlistVideos!.array as! [PlaylistVideo]), at: 0)
                    delegate?.success(type: .playlistCreate)
                } catch {
                    delegate?.showError(type: .playlistCreate, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistCreate, error: .fail, message: "Something went wrong. Please try again.")
            }
        }
    }
}
