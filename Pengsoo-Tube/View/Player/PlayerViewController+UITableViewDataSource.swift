//
//  ViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 6/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel?.getQueueItems().count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: LibraryDetailTableViewCellID, for: indexPath) as? LibraryDetailTableViewCell {
            if let playItems = viewModel?.getQueueItems() {
                let currentItem = playItems[indexPath.row]
                
                cell.tag = indexPath.row
                Util.loadCachedImage(url: currentItem.thumbnailMedium) { (image) in
                    if(cell.tag == indexPath.row) {
                        cell.thumbnail.image = image
                    }
                }
                cell.titleLabel.text = currentItem.videoTitle
                cell.descriptionLabel.text = currentItem.videoDescription
                
                if indexPath.row == viewModel?.getPlayingIndex() {
                    cell.backgroundColor = .systemYellow
                } else {
                    cell.backgroundColor = .systemBackground
                    cell.alpha = 1.0
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel?.getPlayingIndex() != indexPath.row {
            Util.playQueue(at: indexPath.row)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            viewModel!.checkLoadMoreQueue(checkPlayingIndex: false)
        }
    }
}
