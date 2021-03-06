//
//  Util.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 27/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftEntryKit

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
    
    static func getHeaderUrl() -> String? {
        return UserDefaults.standard.string(forKey: AppConstants.key_user_default_home_header_url)
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
    
    static func openPlayer(videoItems: [VideoItemModel], playingIndex: Int, requestType: RequestType) {
        var dictionary:[String:Any] = [:]
        dictionary[AppConstants.notification_userInfo_video_items] = videoItems
        dictionary[AppConstants.notification_userInfo_playing_index] = playingIndex
        dictionary[AppConstants.notification_userInfo_request_type] = requestType
        NotificationCenter.default.post(name: AppConstants.notification_show_miniplayer, object: nil, userInfo: dictionary)
    }
    
    static func playQueue(at: Int) {
        var dictionary:[String:Any] = [:]
        dictionary[AppConstants.notification_userInfo_playing_index] = at
        NotificationCenter.default.post(name: AppConstants.notification_play_quque, object: nil, userInfo: dictionary)
    }
    
    static func updateQueue(canRequestMore: Bool, videoItems: [VideoItemModel]? = nil) {
        var dictionary:[String:Any] = [:]
        dictionary[AppConstants.notification_userInfo_can_request_more] = canRequestMore
        dictionary[AppConstants.notification_userInfo_video_items] = videoItems
        NotificationCenter.default.post(name: AppConstants.notification_add_to_queue, object: nil, userInfo: dictionary)
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
    
    static func createToast(message: String) {
        var attributes: EKAttributes

        // Preset I
        attributes = .topNote
        attributes.displayMode = .inferred
        attributes.name = ""
        attributes.hapticFeedbackType = .success
        attributes.popBehavior = .animated(animation: .translation)
        attributes.entryBackground = .color(color: .standardBackground)
        attributes.shadow = .active(
            with: .init(
                color: .standardContent,
                opacity: 0.5,
                radius: 2
            )
        )
        attributes.statusBar = .light
        attributes.lifecycleEvents.willAppear = {
        }
        attributes.lifecycleEvents.didAppear = {
        }
        attributes.lifecycleEvents.willDisappear = {
        }
        attributes.lifecycleEvents.didDisappear = {
        }
        
        let text = message
        let style = EKProperty.LabelStyle(
            font: .systemFont(ofSize: 15),
            color: .standardContent,
            alignment: .center
        )
        let labelContent = EKProperty.LabelContent(
            text: text,
            style: style
        )
        let contentView = EKNoteMessageView(with: labelContent)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    static func noNetworkToast() {
        createToast(message: "Unable to connect to the Internet.\nPlease try again.")
    }
    
    static func noNetworkPopup(isCancelable: Bool, retryHandler: ((UIAlertAction) -> Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(style: .alert)
            alert.title = "Unable to connect to the Internet"
            alert.message = "Do you wish to try again?"
            
            if isCancelable {
                alert.addAction(title: "Cancel", style: .cancel)
            }
            
            alert.addAction(title: "Retry", handler: retryHandler)
            
            alert.show()
        }
    }
    
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
    }
}
