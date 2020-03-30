//
//  ViewModelDelegate.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation

protocol ViewModelDelegate: class {
    func success(type: RequestType, message: String)
    func showError(type: RequestType, error: ViewModelDelegateError, message: String)
}

extension ViewModelDelegate {
    func success(type: RequestType) {
        success(type: type, message: "")
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError) {
        showError(type: type, error: error, message: "")
    }
}
