//
//  HomeViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper

class HomeViewModel {
    
    var nextPageToken: String = ""
    var listItems:[YoutubeItemModel] = []
    weak var delegate: ViewModelDelegate?
    
    func getPengsooTvList() {
        getPengsooTvList(isInitial: true)
    }
    
    func getPengsooTvList(isInitial: Bool) {
        if checkNetwork() {
            var parameters: Parameters = Parameters()
            parameters[AppConstants.keyType] = AppConstants.valueType
            parameters[AppConstants.keyOrder] = AppConstants.valueOrder
            parameters[AppConstants.keyMaxResult] = AppConstants.valueMaxResult
            parameters[AppConstants.keyChannelId] = AppConstants.valueChannelId
            if !isInitial && nextPageToken.count > 0 { parameters[AppConstants.keyPageToken] = nextPageToken }
            parameters[AppConstants.keyApiKey] = AppConstants.valueApiKey
            
            Alamofire
                .request(AppConstants.baseUrl, method: .get, parameters: parameters)
                .validate()
                .responseObject(completionHandler: { (response: DataResponse<YoutubeListModel>) in
                    switch response.result {
                    case .success(let youtubeListItem):
                        if youtubeListItem.items.count == 0 {
                            self.nextPageToken = ""
                            self.delegate?.showError(error: .noItems)
                        } else {
                            self.nextPageToken = youtubeListItem.nextPageToken
                            self.listItems.append(contentsOf: youtubeListItem.items)
                            self.delegate?.reloadTable()
                        }
                    case .failure(let error):
                        print(error)
                        self.delegate?.showError(error: .networkError)
                    }
                })
        } else {
            self.delegate?.showError(error: .networkError)
        }
    }
    
    func checkNetwork() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
