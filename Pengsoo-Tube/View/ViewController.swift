//
//  ViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import AlamofireImage

class ViewController: UIViewController {
    
    
    let viewModel = HomeViewModel()

    @IBOutlet weak var statusBarImageView: UIImageView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        viewModel.getHeaderInfo()
        viewModel.getPengsooList(type: .pengsooTv)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tvListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        
        let item = viewModel.tvListItems[indexPath.row]
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.tvListItems[indexPath.row]
        var dictionary:[String:Any] = [:]
        dictionary[AppConstants.notification_userInfo_currentPlayingItem] = item
        dictionary[AppConstants.notification_userInfo_headerImgUrl] = viewModel.headerUrl
        NotificationCenter.default.post(name: AppConstants.notification_show_miniplayer, object: nil, userInfo: dictionary)
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < (tableview.tableHeaderView?.frame.height)! {
            let totalHeight = ((statusBarImageView?.frame.height)! + (tableview.tableHeaderView?.frame.height)!)
            let currentHeight = ((statusBarImageView?.frame.height)! + scrollView.contentOffset.y)
            statusBarImageView.alpha = currentHeight/totalHeight
        } else {
            if statusBarImageView.alpha < 1 {
                statusBarImageView.alpha = 1
            }
        }
    }
}

extension ViewController: ViewModelDelegate {
    func reloadHeader() {
        Util.loadCachedImage(url: viewModel.headerUrl) { (image) in
            self.headerImageView!.image = image
        }
    }
    
    func reloadTable(type: RequestType) {
        tableview.reloadData()
    }
    
    func success(message: String) {
        
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        
    }
}
