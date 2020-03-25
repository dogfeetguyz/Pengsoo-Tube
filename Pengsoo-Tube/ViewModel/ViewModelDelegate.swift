//
//  ViewModelDelegate.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation

protocol ViewModelDelegate: class {
    func reloadHeader()
    func reloadTable(type: RequestType)
    func showError(type: RequestType, error: ViewModelDelegateError, message: String)
}

extension ViewModelDelegate {
    func showError(type: RequestType, error: ViewModelDelegateError) {
        showError(type: type, error: error, message: "")
    }
}
