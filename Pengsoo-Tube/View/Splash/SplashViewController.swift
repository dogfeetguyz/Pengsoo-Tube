//
//  SplashViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 6/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SplashViewControll: UIViewController, ViewModelDelegate {

    let viewModel = SplashViewModel()
    @IBOutlet weak var indicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator?.startAnimating()
        viewModel.delegate = self
        viewModel.dispatchHeaderInfo()
    }
    
    func success(type: RequestType, message: String) {
        indicator?.stopAnimating()
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        if error == .fail {
            DispatchQueue.main.async {
                let alert = UIAlertController(style: .alert)
                alert.title = ""
                alert.message = message
                alert.addAction(title: "OK")
                alert.show()
            }
        } else {
            Util.noNetworkPopup(isCancelable: false) { (_) in
                self.viewModel.dispatchHeaderInfo()
            }
        }
    }
}
