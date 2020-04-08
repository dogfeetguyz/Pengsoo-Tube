//
//  InnerTableViewScrollDelegate.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 29/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol InnerTableViewScrollDelegate: class {
    var currentHeaderTop: CGFloat { get }
    
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded()
    func innerTableViewBounceEnded(withScrollView scrollView: UIScrollView)
}

class HomeContentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    
    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    
    private var oldContentOffset = CGPoint.zero
    private var viewModel: HomeViewModel = HomeViewModel()
    private var isDispatched = false
    
    var requestType: RequestType?
    var canRequestMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestMore(_:)), name: AppConstants.notification_load_more_queue, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isDispatched {
            isDispatched = true
            viewModel.delegate = self
            loadingIndicator.startAnimating()
            viewModel.dispatchPengsooList(type: requestType!)
        } else {
            tableView.reloadData()
        }
    }
    
    @objc func requestMore(_ notification: Notification) {
        if canRequestMore {
            if notification.userInfo![AppConstants.notification_userInfo_request_type] as! RequestType == requestType! {
                viewModel.dispatchPengsooList(type: requestType!, isInitial: false)
            }
        } else {
            Util.updateQueue(canRequestMore: canRequestMore)
        }
    }
    
    @IBAction func moreButtonAction(_ sender: UIButton) {
        
        let index = sender.tag
        
        let alert = UIAlertController(style: .actionSheet)
        alert.addAction(title: "Cancel", style: .cancel) //.cancel action will always be at the end
        alert.addAction(image: UIImage(systemName: "play.rectangle.fill"), title: "Watch on Youtube", color: .systemRed, style: .default, isEnabled: true) { (_) in
            
            if let items = self.viewModel.getItemsList(for: self.requestType!) {
                let item = items[index]
                Util.openYoutube(videoId: item.videoId)
            }
        }
        alert.addAction(image: UIImage(systemName: "square.and.arrow.up.on.square.fill"), title: "Share", color: .systemBlue, style: .default, isEnabled: true) { (_) in
            if let items = self.viewModel.getItemsList(for: self.requestType!) {
                let item = items[index]
                let textToShare = [ Util.generateYoutubeUrl(videoId: item.videoId), "Shared from Peng-Ha Tube" ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [.airDrop]
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
       
        alert.addAction(image: UIImage(systemName: "folder.fill.badge.plus"), title: "Add to New Playlist", color: .label, style: .default, isEnabled: true) { (_) in
            let textFieldAlert = UIAlertController(style: .alert, title: "New Playlist", message: "Please input a name for a new playlist")
                    
            weak var weakTextField: TextField?
            let textFieldConfiguration: TextField.Config = { textField in
                textField.left(image: UIImage(systemName: "pencil.and.ellipsis.rectangle"), color: .label)
                textField.leftViewPadding = 12
                textField.becomeFirstResponder()
                textField.borderWidth = 1
                textField.cornerRadius = 8
                textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
                textField.backgroundColor = nil
                textField.textColor = .label
                textField.keyboardAppearance = .default
                textField.keyboardType = .default
                textField.returnKeyType = .done
                weakTextField = textField
            }
            
            textFieldAlert.addOneTextField(configuration: textFieldConfiguration)
            textFieldAlert.addAction(title: "Cancel", style: .cancel) { (_) in
            }
            textFieldAlert.addAction(title: "OK", style: .default) { (_) in
                guard let textField = weakTextField else { return }
                self.viewModel.addtoNewPlaylist(title: textField.text!, at: index, listOf: self.requestType!)
            }
            textFieldAlert.show()
        }
        
        if let playlistItems = viewModel.getPlaylistItems() {
            for playlist in playlistItems {
                alert.addAction(image: UIImage(systemName: "plus.square.on.square"), title: "Add to \(playlist.title)", color: .label, style: .default, isEnabled: true) { (_) in
                    self.viewModel.addToPlaylist(at: index, listOf: self.requestType!, toPlaylist: playlist)
                }
            }
        }
        
        alert.show()
    }
}


extension HomeContentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let items = viewModel.getItemsList(for: requestType!) {
            return items.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCellID, for: indexPath) as? HomeTableViewCell {

            if let items = viewModel.getItemsList(for: requestType!) {
                let item = items[indexPath.row]
                cell.tag = indexPath.row
                Util.loadCachedImage(url: Util.getAvailableThumbnailImageUrl(currentItem: item)) { (image) in
                    if(cell.tag == indexPath.row) {
                        cell.thumbnailImageView.image = image
                    }
                }

                cell.moreButton.tag = indexPath.row
                cell.titleLabel.text = item.videoTitle
                cell.descriptionLabel.text = item.videoDescription
                cell.dateLabel.text = Util.processDate(dateString: item.publishedAt)
                cell.moreButtonTopConstraint.constant = cell.thumbnailImageView.frame.height
                
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let items = viewModel.getItemsList(for: requestType!) {
            Util.openPlayer(videoItems: items, playingIndex: indexPath.row, requestType: requestType!)
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
                self.loadingIndicator.startAnimating()
                self.viewModel.dispatchPengsooList(type: self.requestType!, isInitial: false)
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

extension HomeContentViewController: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        loadingIndicator.stopAnimating()
        tableView.reloadData()
        canRequestMore = true
        Util.updateQueue(canRequestMore: canRequestMore, videoItems: viewModel.getItemsList(for: requestType!))
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        loadingIndicator.stopAnimating()
        if AppConstants.home_tab_types.contains(type) {
            canRequestMore = true
            
            switch error {
            case .noItems:
                canRequestMore = false
                break
            case .fail:
                if message.count > 0 {
                    Util.createToast(message: message)
                }
            case .networkError:
                if let items = self.viewModel.getItemsList(for: self.requestType!) {
                    if items.count == 0 {
                        isDispatched = false
                        Util.noNetworkPopup(isCancelable: true) { (_) in
                            self.isDispatched = true
                            self.loadingIndicator.startAnimating()
                            self.viewModel.dispatchPengsooList(type: self.requestType!)
                        }
                    } else {
                        Util.noNetworkToast()
                    }
                } else {
                    isDispatched = false
                    Util.noNetworkPopup(isCancelable: true) { (_) in
                        self.isDispatched = true
                        self.loadingIndicator.startAnimating()
                        self.viewModel.dispatchPengsooList(type: self.requestType!)
                    }
                }
                
            default:
                break
            }
            Util.updateQueue(canRequestMore: canRequestMore)
        }
    }
}
