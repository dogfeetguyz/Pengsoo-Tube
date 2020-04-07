//
//  BaseViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 7/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Alamofire

class BaseViewModel {
    weak var delegate: ViewModelDelegate?
    
    func checkNetwork() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
