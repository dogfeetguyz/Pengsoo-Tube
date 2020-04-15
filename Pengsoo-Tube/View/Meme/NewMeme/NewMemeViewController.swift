//
//  NewMemeViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 13/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import IQLabelView

class NewMemeViewController: UIViewController {

    let viewModel = MemeViewModel()
    var chosenImage: UIImage?
    var imageSize: CGSize?
    
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var chosenImageView: UIImageView?
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var textOptionView: UIView!
    @IBOutlet weak var textOptionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    var currentlyEditngLabel: IQLabelView?
    var labels: [IQLabelView] = Array()
    var textColorIndex = 4
    var borderColorIndex = 1
    var bgColorIndex = 0
    var shadowIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        if navigationController?.viewControllers.count == 1 {
            let closeButton: UIButton = UIButton.init(type: .custom)
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
            closeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let closeBarButton = UIBarButtonItem(customView: closeButton)
            self.navigationItem.setLeftBarButton(closeBarButton, animated: false)
        }

        let addTextButton: UIButton = UIButton.init(type: .custom)
        addTextButton.setImage(UIImage(systemName: "text.cursor"), for: .normal)
        addTextButton.addTarget(self, action: #selector(addTextButtonAction), for: .touchUpInside)
        addTextButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let addTextBarButton = UIBarButtonItem(customView: addTextButton)

        let saveButton: UIButton = UIButton.init(type: .custom)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        saveButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        let saveBarButton = UIBarButtonItem(customView: saveButton)
        
        self.navigationItem.setRightBarButtonItems([saveBarButton, addTextBarButton], animated: false)
        
        viewWidthConstraint?.constant = imageSize!.width
        viewHeightConstraint?.constant = imageSize!.height
        chosenImageView!.image = chosenImage!
        textOptionView.isHidden = true
        
        containerView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchOutside(_:))))
        gestureView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchOutside(_:))))
    }
    
    @objc func closeButtonAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func addTextButtonAction() {
        if let editingLabel = currentlyEditngLabel {
            editingLabel.hideEditingHandles()
        }
        
        let iqLabel = IQLabelView(frame: CGRect(x: containerView!.center.x - 30, y: containerView!.center.y - 25, width: 60, height: 50))
        iqLabel.delegate = self
        iqLabel.showsContentShadow = false
        iqLabel.isEnableMoveRestriction = false
        iqLabel.borderColor = .systemYellow
        iqLabel.textColor = .white
        iqLabel.fontSize = 21
        iqLabel.fontName = "HelveticaNeue-CondensedBlack"
        iqLabel.setIcons()
        iqLabel.setupTextField()
        iqLabel.setAttributedText(foregroundColor: AppConstants.text_colors[textColorIndex], strokeColor: AppConstants.border_colors[borderColorIndex])
        
        containerView?.addSubview(iqLabel)
        containerView?.isUserInteractionEnabled = true
        
        currentlyEditngLabel = iqLabel
        labels.append(iqLabel)
        
        textOptionView.isHidden = false
    }
    
    @objc func saveButtonAction() {
        viewModel.checkAuthorization()
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        colorCollectionView.reloadData()
    }
    
    @objc func touchOutside(_ touchGesture: UITapGestureRecognizer) {
        if let editingLabel = currentlyEditngLabel {
            editingLabel.hideEditingHandles()
            textOptionView.isHidden = true
        }
    }
}

extension NewMemeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if textOptionSegmentedControl.selectedSegmentIndex == 0 {
            
            return AppConstants.text_colors.count
            
        } else if textOptionSegmentedControl.selectedSegmentIndex == 1 {
            
            return AppConstants.border_colors.count
            
        } else if textOptionSegmentedControl.selectedSegmentIndex == 2 {
            
            return AppConstants.bg_colors.count
            
        } else {
            
            return AppConstants.shadow_colors.count
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMemeViewCellID", for: indexPath)

        if textOptionSegmentedControl.selectedSegmentIndex == 0 {
            
            cell.contentView.backgroundColor = AppConstants.text_colors[indexPath.item]
            
        } else if textOptionSegmentedControl.selectedSegmentIndex == 1 {
            
            cell.contentView.backgroundColor = AppConstants.border_colors[indexPath.item]
            
        } else if textOptionSegmentedControl.selectedSegmentIndex == 2 {
            
            cell.contentView.backgroundColor = AppConstants.bg_colors[indexPath.item]
            
        } else {
            
            cell.contentView.backgroundColor = AppConstants.shadow_colors[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if textOptionSegmentedControl.selectedSegmentIndex == 0 {
            
            textColorIndex = indexPath.item
            currentlyEditngLabel?.setAttributedText(foregroundColor: AppConstants.text_colors[textColorIndex], strokeColor: AppConstants.border_colors[borderColorIndex])
            
        } else if textOptionSegmentedControl.selectedSegmentIndex == 1 {
            
            borderColorIndex = indexPath.item
            currentlyEditngLabel?.setAttributedText(foregroundColor: AppConstants.text_colors[textColorIndex], strokeColor: AppConstants.border_colors[borderColorIndex])
            
        } else if textOptionSegmentedControl.selectedSegmentIndex == 2 {
            
            bgColorIndex = indexPath.item
            currentlyEditngLabel?.setTextBackground(backgroundColor: AppConstants.bg_colors[bgColorIndex])
            
        } else {
            
            shadowIndex = indexPath.item
            currentlyEditngLabel?.showsContentShadow = shadowIndex == 1
        }
    }
}

extension NewMemeViewController: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        DispatchQueue.main.async {
            if type == .memeCheckAuthorization {
                self.viewModel.createAlbum()
            } else if type == .memeCreateAlbum {
                UIGraphicsBeginImageContextWithOptions(self.containerView!.bounds.size, self.containerView!.isOpaque, 0.0)
                defer { UIGraphicsEndImageContext() }
                self.containerView!.drawHierarchy(in: self.containerView!.bounds, afterScreenUpdates: true)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                self.viewModel.saveImage(image: image!)
            } else if type == .memeSave {
                Util.createToast(message: "New Meme saved to your photos")
                NotificationCenter.default.post(name: AppConstants.notification_reload_meme, object: nil, userInfo: nil)
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        if type == .memeCheckAuthorization {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "", message: message, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    } else {
                    }
                }))
                self.present(controller, animated: true, completion: nil)
            }
        } else if type == .memeCreateAlbum {
            Util.createToast(message: message)
        } else if type == .memeSave {
            Util.createToast(message: message)
        }
    }
}

extension NewMemeViewController: IQLabelViewDelegate {
    func labelViewDidClose(_ label: IQLabelView!) {
        if let index = labels.firstIndex(of: label) {
            labels.remove(at: index)
        }
    }
    
    func labelViewDidShowEditingHandles(_ label: IQLabelView!) {
        currentlyEditngLabel = label
        textOptionView.isHidden = false
    }
    
    func labelViewDidStartEditing(_ label: IQLabelView!) {
        currentlyEditngLabel = label
        textOptionView.isHidden = false
        label.setAttributedText(foregroundColor: AppConstants.text_colors[textColorIndex], strokeColor: AppConstants.border_colors[borderColorIndex])
    }
    
    func labelViewDidHideEditingHandles(_ label: IQLabelView!) {
        currentlyEditngLabel = nil
        textOptionView.isHidden = true
    }
    
    func labelViewDidEndEditing(_ label: IQLabelView!) {
        label.setAttributedText(foregroundColor: AppConstants.text_colors[textColorIndex], strokeColor: AppConstants.border_colors[borderColorIndex])
    }
}
