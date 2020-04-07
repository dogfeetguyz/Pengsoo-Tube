//
//  HomeViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import UIKit

class SplashViewModel: BaseViewModel {
    
    func dispatchHeaderInfo() {
        if checkNetwork() {
            var parameters: Parameters = Parameters()
            parameters[AppConstants.keyBrandingId] = AppConstants.valueBrandingId
            parameters[AppConstants.keyApiKey] = AppConstants.valueApiKey
            
            AF.request(AppConstants.baseUrl + AppConstants.partBranding, method: .get, parameters: parameters)
                .validate()
                .responseObject(completionHandler: { (response: AFDataResponse<YoutubeListModel>) in
                    switch response.result {
                    case .success(let youtubeListItem):
                        if youtubeListItem.items.count == 0 {
                            self.delegate?.showError(type:.header, error: .noItems)
                        } else {
                            var headerUrl = ""
                            if youtubeListItem.items.first!.brandingSettings.image.bannerMobileHdImageUrl.count > 0 {
                                headerUrl = youtubeListItem.items.first!.brandingSettings.image.bannerMobileHdImageUrl
                            } else if youtubeListItem.items.first!.brandingSettings.image.bannerMobileMediumHdImageUrl.count > 0 {
                                headerUrl = youtubeListItem.items.first!.brandingSettings.image.bannerMobileMediumHdImageUrl
                            } else if youtubeListItem.items.first!.brandingSettings.image.bannerMobileLowImageUrl.count > 0 {
                                headerUrl = youtubeListItem.items.first!.brandingSettings.image.bannerMobileLowImageUrl
                            } else if youtubeListItem.items.first!.brandingSettings.image.bannerMobileImageUrl.count > 0 {
                                headerUrl = youtubeListItem.items.first!.brandingSettings.image.bannerMobileImageUrl
                            } else {
                                self.delegate?.showError(type:.header, error: .noItems)
                                return
                            }
                            
                            if headerUrl.count > 0 && headerUrl != UserDefaults.standard.string(forKey: AppConstants.key_user_default_home_header_url) {
                                UserDefaults.standard.set(headerUrl, forKey: AppConstants.key_user_default_home_header_url)
                            }
                            self.delegate?.success(type: .header)
                        }
                    case .failure(let error):
                        print(error)
                        self.delegate?.showError(type:.header, error: .networkError)
                    }
                })
        } else {
            self.delegate?.showError(type:.header, error: .networkError)
        }
    }
}
