//
//  MemeDetailViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 15/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import Photos

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var memeImageView: UIImageView!
    
    var asset: PHAsset?
    let viewModel = MemeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self

        let imageSize = CGSize(width: view.width, height: view.height)

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isSynchronous = false

        PHCachingImageManager().requestImage(for: asset!, targetSize: imageSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) -> Void in
            self.memeImageView.image = image
        })
    }

    @IBAction func deleteButtonAction(_ sender: Any) {
        viewModel.deletePhoto(asset: asset!)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        let imageToShare = [ self.memeImageView.image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension MemeDetailViewController: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        DispatchQueue.main.async {
            if type == .memeDelete {
                Util.createToast(message: "Meme deleted")
                NotificationCenter.default.post(name: AppConstants.notification_reload_meme, object: nil, userInfo: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        if type == .memeDelete {
            Util.createToast(message: message)
        }
    }
}
