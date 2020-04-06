//
//  LibraryDetailViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 1/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

class LibraryDetailViewController: UIViewController {
    
    var viewModel: LibraryDetailViewModel?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var manageButton: UIButton!
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        viewModel?.delegate = self
    }
    
    func setupNavigationBar() {

        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = .systemYellow
        nav?.tintColor = .black
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = viewModel?.title
        
        if self.title != "Recent" {
            let editButton: UIButton = UIButton.init(type: .custom)
            editButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
            editButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let editBarButton = UIBarButtonItem(customView: editButton)

            let deleteButton: UIButton = UIButton.init(type: .custom)
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
            deleteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let deleteBarButton = UIBarButtonItem(customView: deleteButton)
            
            self.navigationItem.setRightBarButtonItems([deleteBarButton, editBarButton], animated: false)
        }
    }
    
    @objc func editButtonAction() {
        
        let textFieldAlert = UIAlertController(style: .actionSheet, title: "Rename Playlist", message: "Please input a new name for \(self.title!)")
                
        weak var weakTextField: TextField?
        let textFieldConfiguration: TextField.Config = { textField in
            textField.left(image: UIImage(systemName: "pencil.and.ellipsis.rectangle"), color: .label)
            textField.leftViewPadding = 12
            textField.text = self.title!
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
        textFieldAlert.addAction(title: "OK", style: .cancel) { (_) in
            guard let textField = weakTextField else { return }
            self.viewModel?.updatePlaylist(newTitle: textField.text!)
        }
        
        textFieldAlert.show()
    }
    
    @objc func deleteButtonAction() {
        let alert = UIAlertController(style: .alert)
        alert.title = "Delete Playlist?"
        
        alert.addAction(title: "Cance", style: .cancel)
        alert.addAction(title: "Delete") { (_) in
            self.viewModel?.deletePlaylist()
        }
        
        alert.show()
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        if let playItems = viewModel?.playItems {
            Util.openPlayer(videoItems: playItems, playingIndex: 0)
        }
    }
    
    @IBAction func manageButtonAction(_ sender: Any) {
        if tableView!.isEditing {
            tableView!.setEditing(false, animated: true)
            manageButton.setTitle("Manage", for: .normal)
            manageButton.setImage(UIImage(systemName: "lock"), for: .normal)
        } else {
            tableView!.setEditing(true, animated: true)
            manageButton.setTitle("Done", for: .normal)
            manageButton.setImage(UIImage(systemName: "lock.open"), for: .normal)
        }
    }
    
    @IBAction func clearButtonAction(_ sender: Any) {
        let alert = UIAlertController(style: .alert)
        alert.title = "Clear Playlist?"
        
        alert.addAction(title: "Cance", style: .cancel)
        alert.addAction(title: "Clear") { (_) in
            self.viewModel?.clearItems()
        }
        
        alert.show()
    }
}

extension LibraryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let playItems = viewModel?.playItems {
            return playItems.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: LibraryDetailTableViewCellID, for: indexPath) as? LibraryDetailTableViewCell {
            if let playItems = viewModel?.playItems {
                let currentItem = playItems[indexPath.row]
                
                cell.tag = indexPath.row
                Util.loadCachedImage(url: currentItem.thumbnailMedium) { (image) in
                    if cell.tag == indexPath.row {
                        cell.thumbnail.image = image
                    }
                }
                cell.titleLabel.text = currentItem.videoTitle
                cell.descriptionLabel.text = currentItem.videoDescription
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let playItems = viewModel?.playItems {
            Util.openPlayer(videoItems: playItems, playingIndex: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let alert = UIAlertController(style: .alert)
            alert.title = "Delete Video?"
            
            alert.addAction(title: "Cance", style: .cancel)
            alert.addAction(title: "Delete") { (_) in
                self.viewModel?.deleteItem(at: indexPath.row)
            }
            
            alert.show()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel?.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if self.title == "Recent" {
            return false
        } else {
            return true
        }
    }
}

extension LibraryDetailViewController: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        if type == .playlistDelete {
            navigationController?.popViewController(animated: true)
        } else if type == .playlistUpdate {
            self.title = viewModel?.title
        } else if type == .playlistDetailDelete {
            tableView?.reloadData()
        } else if type == .playlistDetail {
            tableView?.reloadData()
        }
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        switch error {
        case .noItems:
            break
        case .fail:
            Util.createToast(message: message)
        default:
            break
        }
    }
    
}
