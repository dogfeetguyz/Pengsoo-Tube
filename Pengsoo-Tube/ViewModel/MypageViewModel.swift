//
//  MypageViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 24/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import CoreData
import UIKit

class MypageViewModel {
    
    var mylistItems: [Mylist] = []
    weak var delegate: ViewModelDelegate?
    
    func getMylist() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<Mylist> = NSFetchRequest(entityName: String(describing: Mylist.self))
            request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            
            do {
                let fetchedList = try managedOC.fetch(request)
                if fetchedList.count > 0 {
                    mylistItems = fetchedList
                    delegate?.reloadTable(type: .mylist)
                } else {
                    delegate?.showError(type: .mylist, error: .noItems)
                }
            } catch {
                delegate?.showError(type: .mylist, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .mylist, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func createPlaylist(title: String) {
        if title.count == 0 {
            delegate?.showError(type: .mylist, error: .fail, message: "Please enter a name.")
            return
        } else {
            for mylist in mylistItems {
                if mylist.title == title {
                    delegate?.showError(type: .mylist, error: .fail, message: "The name you entered already exists.\nPlease enter another name.")
                    return
                }
            }
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: String(describing: Mylist.self ), in: managedOC)
            let mylist = Mylist(entity: entity!, insertInto: managedOC)
            mylist.updatedAt = Date()
            mylist.title = title
            
            do {
                try managedOC.save()
                mylistItems.append(mylist)
                delegate?.reloadTable(type: .mylist)
            } catch {
                delegate?.showError(type: .mylist, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .mylist, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func deletePlaylist(at: Int) {
        if at < mylistItems.count {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedOC = appDelegate.persistentContainer.viewContext
                managedOC.delete(mylistItems[at])
                
                do {
                    try managedOC.save()
                    mylistItems.remove(at: at)
                    delegate?.reloadTable(type: .mylist)
                } catch {
                    delegate?.showError(type: .mylist, error: .fail, message: "Something went wrong. Please try again.")
                }
            } else {
                delegate?.showError(type: .mylist, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .mylist, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func updatePlaylist(at: Int, newTitle: String) {
        if newTitle.count == 0 {
            delegate?.showError(type: .mylist, error: .fail, message: "Please enter a name.")
            return
        } else {
            for mylist in mylistItems {
                if mylist.title == newTitle {
                    delegate?.showError(type: .mylist, error: .fail, message: "The name you entered already exists.\nPlease enter another name.")
                    return
                }
            }
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedOC = appDelegate.persistentContainer.viewContext

            let mylist = mylistItems[at]
            mylist.updatedAt = Date()
            mylist.title = newTitle
            
            do {
                try managedOC.save()
                delegate?.reloadTable(type: .mylist)
            } catch {
                delegate?.showError(type: .mylist, error: .fail, message: "Something went wrong. Please try again.")
            }
        } else {
            delegate?.showError(type: .mylist, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
}
