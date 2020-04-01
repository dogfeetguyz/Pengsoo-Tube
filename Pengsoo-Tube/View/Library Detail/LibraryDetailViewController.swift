//
//  LibraryDetailViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 1/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

class LibraryDetailViewController: UIViewController {
    
    var libraryDetailType: LibraryDetailType?
    var recentItems: [Recent]?
    var playlistItem: Mylist?
    
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if libraryDetailType == .recent {
            self.title = "Recent"
        } else {
            self.title = playlistItem?.title
        }
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = .systemYellow
        nav?.tintColor = .black
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension LibraryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if libraryDetailType == .recent {
            if let videoItems = recentItems {
                return videoItems.count
            }
        } else {
            if let item = playlistItem {
                if let videoItems = item.videos {
                    return videoItems.count
                }
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: LibraryDetailTableViewCellID, for: indexPath) as? LibraryDetailTableViewCell {
            if libraryDetailType == .recent {
                if let videoItems = recentItems {
                    let currentItem = videoItems[indexPath.row]
                    Util.loadCachedImage(url: currentItem.thumbnailMedium) { (image) in
                        cell.thumbnail.image = image
                    }
                    cell.titleLabel.text = currentItem.videoTitle
                    cell.descriptionLabel.text = currentItem.videoDescription
                }
            } else {
                if let item = playlistItem {
                    if let videoItems = item.videos {
                        let currentItem = videoItems[indexPath.row] as! MyVideo
                        Util.loadCachedImage(url: currentItem.thumbnailMedium) { (image) in
                            cell.thumbnail.image = image
                        }
                        cell.titleLabel.text = currentItem.videoTitle
                        cell.descriptionLabel.text = currentItem.videoDescription
                    }
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if libraryDetailType == .recent {
            if let videoItems = recentItems {
                let currentItem = videoItems[indexPath.row]
                Util.openPlayer(videoItem: currentItem)
            }
        } else {
            if let item = playlistItem {
                if let videoItems = item.videos {
                    let currentItem = videoItems[indexPath.row] as! MyVideo
                    Util.openPlayer(videoItem: currentItem)
                }
            }
        }
    }
}
