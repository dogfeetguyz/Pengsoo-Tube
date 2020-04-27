//
//  MemeViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 13/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import CropViewController
import NVActivityIndicatorView

class MemeViewController: UIViewController {

    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var pengsooVideosButton: UIButton!
    @IBOutlet weak var pengsooVideosBgImageView: UIImageView!
    @IBOutlet weak var memePhotosCollectionView: UICollectionView!
    
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!

    let viewModel = MemeViewModel()
    let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMeme), name: AppConstants.notification_reload_meme, object: nil)
        
        if let headerUrl = Util.getHeaderUrl() {
            if headerUrl.count > 0 {
                Util.loadCachedImage(url: headerUrl) { (image) in
                    self.pengsooVideosBgImageView!.image = image
                }
            }
        }
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.checkAuthorization()
    }
    
    @objc func reloadMeme() {
        viewModel.checkAuthorization()
    }
    
    @IBAction func photoLibraryButtonAction(_ sender: Any) {
        loadingIndicator!.startAnimating()
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        
        let type = kUTTypeImage as String
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            if availableTypes.contains(type) {
                imagePicker.mediaTypes = [type]
            }
        }

        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true) {
            self.loadingIndicator!.stopAnimating()
        }
    }
    
    @IBAction func pengsooVideosButtonAction(_ sender: Any) {
        let viewController = UIStoryboard(name: "NewMemeFromVideosView", bundle: nil).instantiateViewController(identifier: "PengsooVideosNavigationView")
        self.present(viewController, animated: true)
    }
}

extension MemeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeCollectionViewCellID, for: indexPath) as? MemeCollectionViewCell {
            let asset = viewModel.photosArray[indexPath.row]
            let imageSize = CGSize(width: cell.width, height: cell.height)

            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isSynchronous = false

            cell.tag = indexPath.item
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: { (image, info) -> Void in
                if cell.tag == indexPath.item {
                    cell.memeImageView.image = image
                }
            })
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = (view.frame.width-9)/3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let navigationController = UIStoryboard(name: "MemeDetailView", bundle: nil).instantiateInitialViewController() as? UINavigationController {
            if let viewController = navigationController.viewControllers.first as? MemeDetailViewController {
                viewController.asset = self.viewModel.photosArray[indexPath.row]
                self.present(navigationController, animated: true)
            }
        }
    }
}

extension MemeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        loadingIndicator?.startAnimating()
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        picker.dismiss(animated: true, completion: nil)

        let cropController = CropViewController(croppingStyle: .default, image: image)
        cropController.delegate = self
        self.present(cropController, animated: true) {
            self.loadingIndicator?.stopAnimating()
        }
    }
}

extension MemeViewController: CropViewControllerDelegate {
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: false) {
            if let navigationController = UIStoryboard(name: "NewMemeView", bundle: nil).instantiateViewController(identifier: "NewMemeViewNavigationView") as? UINavigationController {
                
                if let viewController = navigationController.viewControllers.first as? NewMemeViewController {
                    viewController.chosenImage = image

                    let maxHeight = self.view.height - 220
                    let maxWidth = self.view.width
                    
                    if maxHeight*(cropRect.size.width/cropRect.size.height) > maxWidth {
                        viewController.imageSize = CGSize(width: maxWidth, height: maxWidth*(cropRect.size.height/cropRect.size.width))
                    } else {
                        viewController.imageSize = CGSize(width: maxHeight*(cropRect.size.width/cropRect.size.height), height: maxHeight)
                    }
                    self.present(navigationController, animated: true)
                }
            }
        }
            
    }
}

extension MemeViewController: ViewModelDelegate {
    func success(type: RequestType, message: String) {

        if type == .memeCheckAuthorization {
            viewModel.createAlbum()
        } else if type == .memeCreateAlbum {
            viewModel.fetchPhotos()
        } else if type == .memePhotos {
            DispatchQueue.main.async {
                self.memePhotosCollectionView.reloadData()
            }
        }
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {

        if type == .memeCheckAuthorization {
        } else if type == .memeCreateAlbum {
        } else if type == .memeSave {
        }
    }
}

