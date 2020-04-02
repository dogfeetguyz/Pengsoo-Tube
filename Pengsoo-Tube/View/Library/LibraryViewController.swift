//
//  LibraryViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 31/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    let viewModel = LibraryViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        viewModel.getRecent()
        viewModel.getPlaylist()
    }

    @IBAction func seeAllButtonAction(_ sender: UIButton) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LibraryDetailViewController") as! LibraryDetailViewController
        
        if sender.tag == 0 {
            viewController.viewModel = LibraryDetailViewModel(playItems: viewModel.recentItems, title: "Recent")
        } else {
            viewController.viewModel = LibraryDetailViewModel(playItems: viewModel.playlistItems[sender.tag-1].videos, title: viewModel.playlistItems[sender.tag-1].title)
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func scrollToTop() {
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.playlistItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: LibraryTableViewCellID, for: indexPath) as? LibraryTableViewCell {
            cell.seeAllButton.tag = indexPath.row
            
            if indexPath.row == 0 {
                cell.titleLabel.text = "Recent"
                cell.videoItems = viewModel.recentItems
            } else {
                let item = viewModel.playlistItems[indexPath.row-1]
                cell.titleLabel.text = item.title
                cell.videoItems = item.videos
            }
            cell.collectionView.reloadData()
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension LibraryViewController: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        if type == .playlist {
            tableView.reloadData()
        } else if type == .recent {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        if error == .noItems {
            if type == .playlist {
                tableView.reloadData()
            } else if type == .recent {
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
    }
    
}
