//
//  ViewModelDelegate.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation

protocol ViewModelDelegate: class {
    func reloadTable(type: HomeViewRequestType)
    func reloadHeader()
    func showError(type: HomeViewRequestType, error: ViewModelDelegateError)
}
