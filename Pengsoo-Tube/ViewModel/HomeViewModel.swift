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
    
    var tvNextPageToken: String = ""
    var tvListItems: [YoutubeItemModel] = []
    
    var youtubeNextPageToken: String = ""
    var youtubeListItems: [YoutubeItemModel] = []
    
    var outsideNextPageToken: String = ""
    var outsideListItems: [YoutubeItemModel] = []
    
    var headerUrl: String = ""
    
    weak var delegate: ViewModelDelegate?
    
    func getPengsooTvList(type: HomeViewRequestType) {
        getPengsooTvList(type:type, isInitial: true)
    }
    
    func getPengsooTvList(type: HomeViewRequestType, isInitial: Bool) {
        
        if checkNetwork() {
            var parameters: Parameters = Parameters()
            if isInitial {
                if type == .pengsooTv {
                    tvNextPageToken = ""
                    tvListItems.removeAll()
                } else if type == .pengsooYoutube {
                    youtubeNextPageToken = ""
                    youtubeListItems.removeAll()
                } else if type == .pengsooOutside {
                    outsideNextPageToken = ""
                    outsideListItems.removeAll()
                }
            } else {
                if type == .pengsooTv && tvNextPageToken.count > 0 {
                    parameters[AppConstants.keyPageToken] = tvNextPageToken
                } else if type == .pengsooYoutube && youtubeNextPageToken.count > 0 {
                    parameters[AppConstants.keyPageToken] = youtubeNextPageToken
                } else if type == .pengsooOutside && outsideNextPageToken.count > 0 {
                    parameters[AppConstants.keyPageToken] = outsideNextPageToken
                } else {
                    self.delegate?.showError(type:type, error: .noItems)
                    return
                }
            }
            
            if type == .pengsooTv {
                parameters[AppConstants.keyPlaylistId] = AppConstants.valuePlaylistGiantTV
            } else if type == .pengsooYoutube {
                parameters[AppConstants.keyPlaylistId] = AppConstants.valuePlaylistYoutube
            } else if type == .pengsooOutside {
                parameters[AppConstants.keyPlaylistId] = AppConstants.valuePlaylistOutside
            }
            
            parameters[AppConstants.keyMaxResult] = AppConstants.valueMaxResult
            parameters[AppConstants.keyApiKey] = AppConstants.valueApiKey
            
            Alamofire
                .request(AppConstants.baseUrl + AppConstants.partSnippet, method: .get, parameters: parameters)
                .validate()
                .responseObject(completionHandler: { (response: DataResponse<YoutubeListModel>) in
                    switch response.result {
                    case .success(let youtubeListItem):
                        if youtubeListItem.items.count == 0 {
                            if type == .pengsooTv {
                                self.tvNextPageToken = ""
                            } else if type == .pengsooYoutube {
                                self.youtubeNextPageToken = ""
                            } else if type == .pengsooOutside {
                                self.outsideNextPageToken = ""
                            }
                            self.delegate?.showError(type:type, error: .noItems)
                        } else {
                            if type == .pengsooTv {
                                self.tvNextPageToken = youtubeListItem.nextPageToken
                                self.tvListItems.append(contentsOf: youtubeListItem.items)
                            } else if type == .pengsooYoutube {
                                self.youtubeNextPageToken = youtubeListItem.nextPageToken
                                self.youtubeListItems.append(contentsOf: youtubeListItem.items)
                            } else if type == .pengsooOutside {
                                self.outsideNextPageToken = youtubeListItem.nextPageToken
                                self.outsideListItems.append(contentsOf: youtubeListItem.items)
                            }
                            self.delegate?.reloadTable(type:type)
                        }
                    case .failure(let error):
                        print(error)
                        self.delegate?.showError(type:type, error: .networkError)
                    }
                })
        } else {
            self.delegate?.showError(type:type, error: .networkError)
        }
    }
    
    func getHeaderInfo() {
        if checkNetwork() {
            var parameters: Parameters = Parameters()
            parameters[AppConstants.keyBrandingId] = AppConstants.valueBrandingId
            parameters[AppConstants.keyApiKey] = AppConstants.valueApiKey
            
            Alamofire
                .request(AppConstants.baseUrl + AppConstants.partBranding, method: .get, parameters: parameters)
                .validate()
                .responseObject(completionHandler: { (response: DataResponse<YoutubeListModel>) in
                    switch response.result {
                    case .success(let youtubeListItem):
                        if youtubeListItem.items.count == 0 {
                            self.delegate?.showError(type:.header, error: .noItems)
                        } else {
                            if youtubeListItem.items[0].brandingSettings.image.bannerMobileHdImageUrl.count > 0 {
                                self.headerUrl = youtubeListItem.items[0].brandingSettings.image.bannerMobileHdImageUrl
                            } else if youtubeListItem.items[0].brandingSettings.image.bannerMobileMediumHdImageUrl.count > 0 {
                                self.headerUrl = youtubeListItem.items[0].brandingSettings.image.bannerMobileMediumHdImageUrl
                            } else if youtubeListItem.items[0].brandingSettings.image.bannerMobileLowImageUrl.count > 0 {
                                self.headerUrl = youtubeListItem.items[0].brandingSettings.image.bannerMobileLowImageUrl
                            } else if youtubeListItem.items[0].brandingSettings.image.bannerMobileImageUrl.count > 0 {
                                self.headerUrl = youtubeListItem.items[0].brandingSettings.image.bannerMobileImageUrl
                            } else {
                                self.delegate?.showError(type:.header, error: .noItems)
                                return
                            }
                            self.delegate?.reloadHeader()
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
    
    func checkNetwork() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
