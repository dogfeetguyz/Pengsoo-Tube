//
//  MemeViewModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 15/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//
import Photos
import UIKit

class MemeViewModel: BaseViewModel {
    
    var assetCollection: PHAssetCollection!
    var photosArray: [PHAsset] = Array()
    
    func checkAuthorization() {
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            delegate?.success(type: .memeCheckAuthorization)
        } else {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    self.delegate?.success(type: .memeCheckAuthorization)
                } else {
                    self.delegate?.showError(type: .memeCheckAuthorization, error: .fail, message: "Photos permission denied")
                }
            }
        }
    }
    
    func createAlbum() {
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", AppConstants.memeAlbumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

            if let firstObject: AnyObject = collection.firstObject {
                return (firstObject as! PHAssetCollection)
            }

            return nil
        }

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            delegate?.success(type: .memeCreateAlbum)
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: AppConstants.memeAlbumName)
            }) { success, error in
                
                if success {
                    self.assetCollection = fetchAssetCollectionForAlbum()
                    self.delegate?.success(type: .memeCreateAlbum)
                } else {
                    if error != nil {
                        self.delegate?.showError(type: .memeCreateAlbum, error: .fail, message: error!.localizedDescription)
                    } else {
                        self.delegate?.showError(type: .memeCreateAlbum, error: .fail, message: "Something went wrong. Please try again.")
                    }
                }
            }
        }
    }
    
    func saveImage(image: UIImage) {
        if assetCollection == nil {
            delegate?.showError(type: .memeSave, error: .fail, message: "Something went wrong. Please try again.")
        } else {
            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                albumChangeRequest!.addAssets([assetPlaceholder] as NSFastEnumeration)
            }) { (success, error) in
                if success {
                    self.delegate?.success(type: .memeSave)
                } else {
                    if error != nil {
                        self.delegate?.showError(type: .memeSave, error: .fail, message: error!.localizedDescription)
                    } else {
                        self.delegate?.showError(type: .memeSave, error: .fail, message: "Something went wrong. Please try again.")
                    }
                }
            }
        }
    }
    
    func fetchPhotos() {
        photosArray.removeAll()
        
        var assetCollection = PHAssetCollection()
        var photoAssets = PHFetchResult<AnyObject>()
        let fetchOptions = PHFetchOptions()

        fetchOptions.predicate = NSPredicate(format: "title = %@", AppConstants.memeAlbumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let firstObject = collection.firstObject{
            assetCollection = firstObject
            photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil) as! PHFetchResult<AnyObject>
            photoAssets.enumerateObjects{(object: AnyObject!,
                index: Int,
                stop: UnsafeMutablePointer<ObjCBool>) in

                if let asset = object as? PHAsset {
                    self.photosArray.append(asset)
                }
                
                if index == photoAssets.count - 1 {
                    self.delegate?.success(type: .memePhotos)
                }
            }
        } else {
            self.delegate?.showError(type: .memePhotos, error: .fail, message: "Something went wrong. Please try again.")
        }
    }
    
    func deletePhoto(asset: PHAsset) {
        let arrayToDelete = NSArray(object: asset)
        PHPhotoLibrary.shared().performChanges( {
            PHAssetChangeRequest.deleteAssets(arrayToDelete)},
            completionHandler: {
                success, error in
                if success {
                    self.delegate?.success(type: .memeDelete)
                } else {
                    if error != nil {
                        self.delegate?.showError(type: .memeDelete, error: .fail, message: error!.localizedDescription)
                    } else {
                        self.delegate?.showError(type: .memeDelete, error: .fail, message: "Something went wrong. Please try again.")
                    }
                }
        })
//
//        if assetCollection == nil {
//            delegate?.showError(type: .memeDelete, error: .fail, message: "Something went wrong. Please try again.")
//        } else {
//            PHPhotoLibrary.shared().performChanges({
//                let assets = NSArray(object: asset)
//                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
//                albumChangeRequest!.removeAssets(assets)
//            }) { (success, error) in
//                if success {
//                    self.delegate?.success(type: .memeDelete)
//                } else {
//                    if error != nil {
//                        self.delegate?.showError(type: .memeDelete, error: .fail, message: error!.localizedDescription)
//                    } else {
//                        self.delegate?.showError(type: .memeDelete, error: .fail, message: "Something went wrong. Please try again.")
//                    }
//                }
//            }
//        }
    }
}
