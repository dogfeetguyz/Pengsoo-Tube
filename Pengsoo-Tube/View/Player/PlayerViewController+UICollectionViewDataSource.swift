//
//  PlayerViewController+UICollectionViewDataSource.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 6/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

extension PlayerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel?.getQueueItems().count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCollectionViewCellID, for: indexPath) as? LibraryCollectionViewCell {
            if let playItems = viewModel?.getQueueItems() {
                let currentItem = playItems[indexPath.row]
                
                Util.loadCachedImage(url: currentItem.thumbnailMedium) { (image) in
                    cell.thumnail.image = image
                }
                cell.titleLabel.text = currentItem.videoTitle
                
                if indexPath.row == viewModel?.getPlayingIndex() {
                    cell.backgroundColor = .systemYellow
                } else {
                    cell.backgroundColor = .systemBackground
                    cell.alpha = 1.0
                }
                return cell
            }
        }

        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if viewModel?.getPlayingIndex() != indexPath.item {
            Util.playQueue(at: indexPath.item)
        }
    }
}
