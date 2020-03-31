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
    
    var recentItems: [Recent] = []
    var playlistItems: [Mylist] = []
    weak var delegate: ViewModelDelegate?
        
    func getRecent() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<Recent> = NSFetchRequest(entityName: String(describing: Recent.self))
            
            do {
                let fetchedList = try managedOC.fetch(request)
                if fetchedList.count > 0 {
                    recentItems = fetchedList.reversed()
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
            let request: NSFetchRequest<Mylist> = NSFetchRequest(entityName: String(describing: Mylist.self))
//            request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            
            do {
                let fetchedList = try managedOC.fetch(request)
                if fetchedList.count > 0 {
                    playlistItems = fetchedList
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

                let entity = NSEntityDescription.entity(forEntityName: String(describing: Mylist.self ), in: managedOC)
                let playlist = Mylist(entity: entity!, insertInto: managedOC)
                playlist.updatedAt = Date()
                playlist.title = title
                
                do {
                    try managedOC.save()
                    playlistItems.append(playlist)
                    delegate?.success(type: .playlistCreate)
                } catch {
                    delegate?.showError(type: .playlistCreate, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistCreate, error: .fail, message: "Something went wrong. Please try again.")
            }
        }
    }
    
    func deletePlaylist(at: Int) {
        if at < playlistItems.count {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext
                managedOC.delete(playlistItems[at])
                
                do {
                    try managedOC.save()
                    playlistItems.remove(at: at)
                    delegate?.success(type: .playlistDelete)
                } catch {
                    delegate?.showError(type: .playlistDelete, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .playlistDelete, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .playlistDelete, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func updatePlaylist(at: Int, newTitle: String) {
        if newTitle.count == 0 {
            delegate?.showError(type: .playlistUpdate, error: .fail, message: "Please enter a name.")
            return
        } else {
            for playlist in playlistItems {
                if playlist.title == newTitle {
                    delegate?.showError(type: .playlistUpdate, error: .fail, message: "The name you entered already exists.\nPlease enter another name.")
                    return
                }
            }
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext

            let playlist = playlistItems[at]
            playlist.updatedAt = Date()
            playlist.title = newTitle
            
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
