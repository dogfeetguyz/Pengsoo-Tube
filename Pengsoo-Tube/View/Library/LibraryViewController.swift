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
        viewModel.getPlaylist()
    }

    @IBAction func seeAllButtonAction(_ sender: UIButton) {
        let index = sender.tag
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
            } else {
                let item = viewModel.playlistItems[indexPath.row-1]
                cell.titleLabel.text = item.title
                cell.playlistItem = item
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
        }
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        
    }
    
}
