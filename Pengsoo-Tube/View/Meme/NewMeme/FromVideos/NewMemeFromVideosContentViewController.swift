//
//  InnerTableViewScrollDelegate.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 29/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class NewMemeFromVideosContentViewController: UIViewController {

    struct Page {
        var name = ""
        var vc = NewMemeFromVideosContentViewController()
        
        init(with _name: String, _vc: NewMemeFromVideosContentViewController) {
            name = _name
            vc = _vc
        }
    }

    struct PageCollection {
        var pages = [Page]()
        var selectedPageIndex = 0
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    
    private var viewModel: HomeViewModel = HomeViewModel()
    private var isDispatched = false
    
    var requestType: RequestType?
    var canRequestMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}


extension NewMemeFromVideosContentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let items = viewModel.getItemsList(for: requestType!) {
            return items.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: LibraryDetailTableViewCellID, for: indexPath) as? LibraryDetailTableViewCell {

            if let items = viewModel.getItemsList(for: requestType!) {
                let item = items[indexPath.row]
                cell.tag = indexPath.row
                Util.loadCachedImage(url: Util.getAvailableThumbnailImageUrl(currentItem: item)) { (image) in
                    if(cell.tag == indexPath.row) {
                        cell.thumbnail.image = image
                    }
                }
                cell.titleLabel.text = item.videoTitle
                cell.descriptionLabel.text = item.videoDescription
                
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let items = viewModel.getItemsList(for: requestType!) {
            let viewController = UIStoryboard(name: "NewMemeFromVideosView", bundle: nil).instantiateViewController(identifier: "PickedVideoView") as! NewMemePickedVideoViewController
            viewController.videoItem = items[indexPath.row]
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension NewMemeFromVideosContentViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // dispatch more
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if canRequestMore {
                canRequestMore = false
                self.loadingIndicator.startAnimating()
                self.viewModel.dispatchPengsooList(type: self.requestType!, isInitial: false)
            }
        }
    }
}

extension NewMemeFromVideosContentViewController: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        loadingIndicator.stopAnimating()
        tableView.reloadData()
        canRequestMore = true
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
        }
    }
}
