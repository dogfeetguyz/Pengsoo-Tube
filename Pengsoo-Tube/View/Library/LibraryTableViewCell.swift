//
//  LibraryTableViewCell.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 31/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

let LibraryTableViewCellID = "LibraryTableViewCell"

class LibraryTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var playlistItem: Mylist?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension LibraryTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let item = playlistItem {
            if let videos = item.videos {
                return videos.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCollectionViewCellID, for: indexPath) as? LibraryCollectionViewCell {
            if let item = playlistItem {
                if let videos = item.videos {
                    let videoItem = videos[indexPath.item] as? MyVideo
                    cell.titleLabel.text = videoItem?.videoTitle
                    Util.loadCachedImage(url: videoItem?.thumbnailMedium) { (image) in
                        cell.thumnail.image = image
                    }
                    return cell
                }
            }
        }

        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let item = playlistItem {
            if let videos = item.videos {
                let videoItem = videos[indexPath.item] as? MyVideo
                let playItem = PlayItemModel(videoId: videoItem!.videoId!,
                                             videoTitle: videoItem!.videoTitle!,
                                             videoDescription: videoItem!.videoDescription!,
                                             thumbnailDefault: videoItem!.thumbnailDefault!,
                                             thumbnailMedium: videoItem!.thumbnailMedium!,
                                             thumbnailHigh: videoItem!.thumbnailHigh!)
                var dictionary:[String:Any] = [:]
                dictionary[AppConstants.notification_userInfo_currentPlayingItem] = playItem
                NotificationCenter.default.post(name: AppConstants.notification_show_miniplayer, object: nil, userInfo: dictionary)
            }
        }
    }
}
