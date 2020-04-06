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

    let viewModel = HomeViewModel()
    @IBOutlet weak var indicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator?.startAnimating()
        viewModel.delegate = self
        viewModel.getHeaderInfo()
    }
    
    func success(type: RequestType, message: String) {
        if viewModel.headerUrl.count > 0 {
            if viewModel.headerUrl != UserDefaults.standard.string(forKey: AppConstants.key_user_default_home_header_url) {
                UserDefaults.standard.set(viewModel.headerUrl, forKey: AppConstants.key_user_default_home_header_url)
            }
        }
        
        indicator?.stopAnimating()
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        Util.noNetworkPopup(isCancelable: false) { (_) in            
            self.viewModel.getHeaderInfo()
        }
    }
}
