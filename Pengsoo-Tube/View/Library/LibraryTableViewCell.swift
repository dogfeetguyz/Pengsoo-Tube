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
    
    var videoItems: [VideoItemModel]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.1)
        seeAllButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension LibraryTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _videoItems = videoItems {
            return _videoItems.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCollectionViewCellID, for: indexPath) as? LibraryCollectionViewCell {
            if let _videoItems = videoItems {
                let videoItem = _videoItems[indexPath.item]
                cell.titleLabel.text = videoItem.videoTitle
                Util.loadCachedImage(url: videoItem.thumbnailMedium) { (image) in
                    cell.thumnail.image = image
                }
            }
            return cell
        }

        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _videoItems = videoItems {
            Util.openPlayer(videoItems: _videoItems, playingIndex: indexPath.item)
        }
    }
}
