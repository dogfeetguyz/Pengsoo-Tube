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
    
    static func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    static func processDate(dateString: String) -> String {
        let splittedStrings = dateString.split(separator: "T")
        
        if splittedStrings.count > 1 {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let date = dateformatter.date(from: String(splittedStrings[0]))

            let requestedComponent: Set<Calendar.Component> = [ .day]
            let timeDifference = Calendar.current.dateComponents(requestedComponent, from: date!, to: Date())
            
            if timeDifference.day! == 0 {
                return "Today"
            } else if timeDifference.day! < 7 {
                let day: Int = timeDifference.day!
                return String(format: "%d %@ ago", day, day == 1 ? "day" : "days" )
            } else if timeDifference.day! < 28 {
                let week: Int = timeDifference.day!/7
                return String(format: "%d %@ ago", week, week == 1 ? "week" : "weeks" )
            } else if timeDifference.day! < 365 {
                var month = Int(Double(timeDifference.day!)/(365.0/12.0))
                if month == 0 {
                    month += 1
                }
                return String(format: "%d %@ ago", month, month == 1 ? "month" : "months" )
            } else {
                let year: Int = timeDifference.day!/365
                return String(format: "%d %@ ago", year, year == 1 ? "year" : "years" )
            }
        }
        
        return ""
    }
    
    static func openYoutube(videoId: String) {
        var youtubeUrl = URL(string:"youtube://\(videoId)")!
        if UIApplication.shared.canOpenURL(youtubeUrl){
            UIApplication.shared.open(youtubeUrl, options: [:], completionHandler: nil)
        } else{
            youtubeUrl = URL(string:generateYoutubeUrl(videoId: videoId))!
            UIApplication.shared.open(youtubeUrl, options: [:], completionHandler: nil)
        }
    }
    
    static func generateYoutubeUrl(videoId: String) -> String {
        return "https://www.youtube.com/watch?v=\(videoId)"
    }
    
    static func openPlayer(videoItems: [VideoItemModel], playingIndex: Int) {
        var dictionary:[String:Any] = [:]
        dictionary[AppConstants.notification_userInfo_video_items] = videoItems
        dictionary[AppConstants.notification_userInfo_playing_index] = playingIndex
        NotificationCenter.default.post(name: AppConstants.notification_show_miniplayer, object: nil, userInfo: dictionary)
    }
    
    static func playQueue(at: Int) {
        var dictionary:[String:Any] = [:]
        dictionary[AppConstants.notification_userInfo_playing_index] = at
        NotificationCenter.default.post(name: AppConstants.notification_play_quque, object: nil, userInfo: dictionary)
    }
    
    static func getAvailableThumbnailImageUrl(currentItem: VideoItemModel) -> String {
        if currentItem.thumbnailHigh.count > 0 {
            return currentItem.thumbnailHigh
        } else if currentItem.thumbnailMedium.count > 0 {
            return currentItem.thumbnailMedium
        } else if currentItem.thumbnailDefault.count > 0 {
            return currentItem.thumbnailDefault
        } else {
            return ""
        }
    }

    struct Page {
        var name = ""
        var vc = HomeContentViewController()
        
        init(with _name: String, _vc: HomeContentViewController) {
            name = _name
            vc = _vc
        }
    }

    struct PageCollection {
        var pages = [Page]()
        var selectedPageIndex = 0 //The first page is selected by default in the beginning
    }
}
