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
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection)
}

class HomeContentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    
    private var dragDirection: DragDirection = .Up
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
}


extension HomeContentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if viewModel != nil {
            
            switch requestType {
            case .pengsooTv:
                return (viewModel?.tvListItems.count)!
            case .pengsooYoutube:
                return (viewModel?.youtubeListItems.count)!
            case .pengsooOutside:
                return (viewModel?.outsideListItems.count)!
            default:
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCellID, for: indexPath) as? HomeTableViewCell {

            if viewModel != nil {
                var items:[YoutubeItemModel]?
                
                switch requestType {
                case .pengsooTv:
                    items = viewModel?.tvListItems
                case .pengsooYoutube:
                    items = viewModel?.youtubeListItems
                case .pengsooOutside:
                    items = viewModel?.outsideListItems
                default:
                    break
                }
                
                if items != nil {
                    let item = items![indexPath.row]
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

                    cell.titleLabel.text = item.snippet.title
                    cell.descriptionLabel.text = item.snippet.description


                    return cell
                }
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel != nil {
            var items:[YoutubeItemModel]?
            
            switch requestType {
            case .pengsooTv:
                items = viewModel?.tvListItems
            case .pengsooYoutube:
                items = viewModel?.youtubeListItems
            case .pengsooOutside:
                items = viewModel?.outsideListItems
            default:
                break
            }
            
            if items != nil {
                let item = items![indexPath.row]
                var dictionary:[String:Any] = [:]
                dictionary[AppConstants.notification_userInfo_currentPlayingItem] = item
                dictionary[AppConstants.notification_userInfo_headerImgUrl] = viewModel!.headerUrl
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
                
                dragDirection = .Up
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
            
            if delta < 0,
                scrollView.contentOffset.y < 0 {
                dragDirection = .Down
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
        }
        oldContentOffset = scrollView.contentOffset
        
        
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if canRequestMore {
                canRequestMore = false
                viewModel?.getPengsooList(type: requestType!, isInitial: false)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false && scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
}
