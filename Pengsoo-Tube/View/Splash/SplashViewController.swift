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
        DispatchQueue.main.async {
            let alert = UIAlertController(style: .alert)
            alert.title = "Unable to connect to the Internet"
            alert.message = "Do you wish to try again?"
            
            alert.addAction(title: "Retry") { (_) in
                self.viewModel.getHeaderInfo()
            }
            
            alert.show()
        }
    }
}
