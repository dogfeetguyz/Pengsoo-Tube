//
//  InnerTableViewScrollDelegate.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 29/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

protocol InnerTableViewScrollDelegate: class {
    var currentHeaderTop: CGFloat { get }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded()
    func innerTableViewBounceEnded(withScrollView scrollView: UIScrollView)
}

class HomeContentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    
    private var oldContentOffset = CGPoint.zero
    
    var requestType: RequestType?
    var viewModel: HomeViewModel?
    var canRequestMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func moreButtonAction(_ sender: UIButton) {
        
        let index = sender.tag
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        alertController.addAction(cancelAction)
        
        let watchOnYoutubeAction = UIAlertAction(title: "Watch on Youtube", style: .default) { _ in
            if self.viewModel != nil {
                if let items = self.viewModel?.getItemsList(for: self.requestType!) {
                    let item = items[index]
                    Util.openYoutube(videoId: item.snippet.resourceId.videoId)
                }
            }
        }
        alertController.addAction(watchOnYoutubeAction)
        
        let addToNewListAction = UIAlertAction(title: "Add to New Playlist", style: .default) { _ in
            let title = "New Playlist"
            let message = "Please input a name for a new playlist"
            let cancelButtonTitle = "Cancel"
            let otherButtonTitle = "OK"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addTextField { _ in
            }

            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            }
            
            let otherAction = UIAlertAction(title: otherButtonTitle, style: .default) { _ in
                guard let textField = alertController.textFields?.first else { return }
                self.viewModel?.addtoNewPlaylist(title: textField.text!, at: index, listOf: self.requestType!)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(otherAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        alertController.addAction(addToNewListAction)
        
        if let playlistItems = viewModel?.getPlaylistItems() {
            for playlist in playlistItems {
                if let title = playlist.title {
                    let addToAction = UIAlertAction(title: "Add to \(title)", style: .default) { _ in
                        self.viewModel?.addToPlaylist(at: index, listOf: self.requestType!, toPlaylist: playlist)
                    }
                    alertController.addAction(addToAction)
                }
            }
        }
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            let selectedCell = tableView.cellForRow(at: IndexPath(row: index, section: 0))!
            popoverPresentationController.sourceRect = selectedCell.frame
            popoverPresentationController.sourceView = view
            popoverPresentationController.permittedArrowDirections = .up
        }
        
        present(alertController, animated: true, completion: nil)
    }
}


extension HomeContentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if viewModel != nil {
            if let items = viewModel?.getItemsList(for: requestType!) {
                return items.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCellID, for: indexPath) as? HomeTableViewCell {

            if viewModel != nil {
                if let items = viewModel?.getItemsList(for: requestType!) {
                    let item = items[indexPath.row]
                    var imgUrl: String?
                    if item.snippet.thumbnails.high.url.count > 0 {
                        imgUrl = item.snippet.thumbnails.high.url
                    } else if item.snippet.thumbnails.medium.url.count > 0 {
                        imgUrl = item.snippet.thumbnails.medium.url
                    } else if item.snippet.thumbnails.small.url.count > 0 {
                        imgUrl = item.snippet.thumbnails.small.url
                    }

                    Util.loadCachedImage(url: imgUrl) { (image) in
                        cell.thumbnailImageView.image = image
                    }

                    cell.moreButton.tag = indexPath.row
                    cell.titleLabel.text = item.snippet.title
                    cell.descriptionLabel.text = item.snippet.description
                    cell.dateLabel.text = Util.processDate(dateString: item.snippet.publishedAt)
                    cell.moreButtonTopConstraint.constant = cell.thumbnailImageView.frame.height
                    
                    return cell
                }
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel != nil {
            if let items = viewModel?.getItemsList(for: requestType!) {
                let item = items[indexPath.row]
                let playItem = PlayItemModel(videoId: item.snippet.resourceId.videoId,
                                             videoTitle: item.snippet.title,
                                             videoDescription: item.snippet.description,
                                             thumbnailDefault: item.snippet.thumbnails.high.url,
                                             thumbnailMedium: item.snippet.thumbnails.medium.url,
                                             thumbnailHigh: item.snippet.thumbnails.small.url)
                var dictionary:[String:Any] = [:]
                dictionary[AppConstants.notification_userInfo_currentPlayingItem] = playItem
                NotificationCenter.default.post(name: AppConstants.notification_show_miniplayer, object: nil, userInfo: dictionary)
            }
        }
    }
}

extension HomeContentViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        let topViewCurrentTopConst = innerTableViewScrollDelegate?.currentHeaderTop
        
        if let topViewUnwrappedTop = topViewCurrentTopConst {
            
            if delta > 0,
                topViewUnwrappedTop > topViewTopConstraintRange!.lowerBound,
                scrollView.contentOffset.y > 0 {
                
                if scrollView.isScrollEnabled {
                    innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                }
                scrollView.contentOffset.y -= delta
            }
            
            if delta < 0,
                scrollView.contentOffset.y < 0 {
                    if scrollView.isScrollEnabled {
                        innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                    }
                scrollView.contentOffset.y -= delta
            }
        }
        oldContentOffset = scrollView.contentOffset
        
        
        // dispatch more
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if canRequestMore {
                canRequestMore = false
                viewModel?.dispatchPengsooList(type: requestType!, isInitial: false)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false && scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded()
        } else if decelerate == true {
            self.innerTableViewScrollDelegate?.innerTableViewBounceEnded(withScrollView: scrollView)
        }
    }
}
