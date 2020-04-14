//
//  PickedVideoViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 13/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import AVFoundation
import XCDYouTubeKit
import CropViewController


class NewMemePickedVideoViewController: UIViewController {
    
    var videoItem: VideoItemModel?
    var player: AVPlayer?
    
    @IBOutlet weak var playerView: UIView?
    @IBOutlet weak var progressSlider: UISlider!
    
    let playerViewModel = PlayerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadVideo()
    }
    
    func loadVideo() {
        XCDYouTubeClient.default().getVideoWithIdentifier(videoItem!.videoId) { (video, error) in
            self.player = AVPlayer(url: video!.streamURL)
            let playerLayer = AVPlayerLayer(player: self.player!)
            playerLayer.frame = self.playerView!.bounds
            self.playerView!.layer.insertSublayer(playerLayer, at: 0)
            self.player!.pause()
            
        }
    }
    
    @IBAction func seekAction(_ sender: Any, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                player!.pause()
            case .moved:
                let duration = player?.currentItem?.asset.duration.seconds
                let playTime = duration! * Double(progressSlider.value)
                let playTimeCmTime = CMTime(seconds: playTime, preferredTimescale: 1000000)
                player!.seek(to: playTimeCmTime)
            case .ended:
                player!.pause()
            default:
                break
            }
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        player!.pause()
        
            guard let player = player ,
                let asset = player.currentItem?.asset else {
                    return
            }

            let imageGenerator = AVAssetImageGenerator(asset: asset)
            do {
                let imageRef = try imageGenerator.copyCGImage(at: player.currentTime(), actualTime: nil)
                let image = UIImage(cgImage: imageRef)

                let cropController = CropViewController(croppingStyle: .default, image: image)
                cropController.delegate = self
                self.present(cropController, animated: true, completion: nil)
            } catch {
                
            }
    }
}

extension NewMemePickedVideoViewController: CropViewControllerDelegate {
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: false) {
            if let viewController = UIStoryboard(name: "NewMemeView", bundle: nil).instantiateInitialViewController() as? NewMemeViewController {
                viewController.chosenImage = image
                self.navigationController!.pushViewController(viewController, animated: false)
            }
        }
            
    }
}
