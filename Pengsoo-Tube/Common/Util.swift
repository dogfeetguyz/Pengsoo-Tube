//
//  Util.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 27/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import AlamofireImage

class Util {
    static func generateImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    static func loadCachedImage(url: String?, complete work: @escaping @convention(block) (_ image: Image) -> Void) {
        if url != nil && url!.count > 0 {
            let imageCache = AutoPurgingImageCache()
            let urlRequest = URLRequest(url: URL(string: url!)!)
            
            if let cachedHeaderImage = imageCache.image(for: urlRequest) {
                work(cachedHeaderImage)
            } else {
                let downloader = ImageDownloader()
                downloader.download(urlRequest) { response in
                    if case .success(let downloadedImage) = response.result {
                        imageCache.add(downloadedImage, for: urlRequest)
                        work(downloadedImage)
                    }
                }
            }
        }
    }

    struct Page {
        var name = ""
        var vc = UIViewController()
        
        init(with _name: String, _vc: UIViewController) {
            name = _name
            vc = _vc
        }
    }

    struct PageCollection {
        var pages = [Page]()
        var selectedPageIndex = 0 //The first page is selected by default in the beginning
    }
}
