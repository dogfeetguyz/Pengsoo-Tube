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
    @IBOutlet weak var newButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.1)
        newButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        viewModel.getRecent()
        viewModel.getPlaylist()
    }

    @IBAction func seeAllButtonAction(_ sender: UIButton) {
        let viewController = UIStoryboard(name: "LibraryDetailView", bundle: nil).instantiateViewController(withIdentifier: "LibraryDetailViewController") as! LibraryDetailViewController
        
        if sender.tag == 0 {
            viewController.viewModel = LibraryDetailViewModel(playItems: viewModel.recentItems, title: "Recent")
        } else {
            viewController.viewModel = LibraryDetailViewModel(playItems: viewModel.playlistItems[sender.tag-1].videos, title: viewModel.playlistItems[sender.tag-1].title)
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func newButtonAction(_ sender: Any) {
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
            self.viewModel.createPlaylist(title: textField.text!)
        }
        textFieldAlert.show()
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
            
            if cell.videoItems != nil && cell.videoItems!.count > 0 {
                cell.collectionView.isHidden = false
                cell.noItemsView.isHidden = true
                
                cell.collectionView.reloadData()
            } else {
                cell.collectionView.isHidden = true
                cell.noItemsView.isHidden = false
            }
            
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
        } else if type == .playlistCreate {
            Util.createToast(message: message)
            tableView.reloadData()
        }
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        switch error {
        case .noItems:
            if type == .playlist {
                tableView.reloadData()
            } else if type == .recent {
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        case .fail:
            Util.createToast(message: message)
        default:
            break
        }
    }
    
}
