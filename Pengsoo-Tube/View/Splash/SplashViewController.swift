//
//  SplashViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 6/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

class SplashViewControll: UIViewController, ViewModelDelegate {

    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.getHeaderInfo()
    }
    
    func success(type: RequestType, message: String) {
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
