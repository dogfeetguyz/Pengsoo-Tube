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
import NVActivityIndicatorView


class NewMemePickedVideoViewController: UIViewController {
    
    var videoItem: VideoItemModel?
    var player: AVPlayer?
    
    @IBOutlet weak var playerView: UIView?
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var indicator: NVActivityIndicatorView?
    
    let playerViewModel = PlayerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if navigationController?.viewControllers.count == 1 {
            let closeButton: UIButton = UIButton.init(type: .custom)
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
            closeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let closeBarButton = UIBarButtonItem(customView: closeButton)
            self.navigationItem.setLeftBarButton(closeBarButton, animated: false)
        }
        
        loadVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        indicator?.stopAnimating()
        indicator = nil
        player = nil
    }
    
    func loadVideo() {
        indicator?.startAnimating()
        XCDYouTubeClient.default().getVideoWithIdentifier(videoItem!.videoId) { (video, error) in
            
            if self.player != nil {
                self.player = AVPlayer(url: video!.streamURL)
                self.player!.isMuted = true
                self.player!.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
                self.player!.pause()
                
                let playerLayer = AVPlayerLayer(player: self.player!)
                playerLayer.frame = self.playerView!.bounds
                self.playerView!.layer.insertSublayer(playerLayer, at: 0)
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let playerObject = object as? AVPlayer {
            if keyPath == "status" {
                indicator?.stopAnimating()
                if playerObject.status == AVPlayer.Status.readyToPlay {
                    progressSlider.isHidden = false
                } else {

                    let controller = UIAlertController(title: "Error", message: "Something went wrong. Please try again.", preferredStyle: .alert)
                    controller.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    controller.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                        self.loadVideo()
                    }))
                    present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    func seekToCurrentSliderValue() {
        let duration = player?.currentItem?.asset.duration.seconds
        let playTime = duration! * Double(progressSlider.value)
        let playTimeCmTime = CMTime(seconds: playTime, preferredTimescale: 1000000)
        self.player!.seek(to: playTimeCmTime)
    }
    
    func adjustAfterSeeking() {
        player!.play()
        if player!.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.adjustAfterSeeking()
            }
        } else {
            player?.pause()
            indicator?.stopAnimating()
        }
    }
    
    @IBAction func seekAction(_ sender: Any, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                indicator?.startAnimating()
            case .moved:
                seekToCurrentSliderValue()
            case .ended:
                adjustAfterSeeking()
            default:
                indicator?.stopAnimating()
            }
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if progressSlider.isHidden == false {
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
    
    @objc func closeButtonAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension NewMemePickedVideoViewController: CropViewControllerDelegate {
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: false) {
            if let viewController = UIStoryboard(name: "NewMemeView", bundle: nil).instantiateInitialViewController() as? NewMemeViewController {
                viewController.chosenImage = image

                let maxHeight = self.view.height - 220
                let maxWidth = self.view.width
                
                if maxHeight*(cropRect.size.width/cropRect.size.height) > maxWidth {
                    viewController.imageSize = CGSize(width: maxWidth, height: maxWidth*(cropRect.size.height/cropRect.size.width))
                } else {
                    viewController.imageSize = CGSize(width: maxHeight*(cropRect.size.width/cropRect.size.height), height: maxHeight)
                }
                
                self.navigationController!.pushViewController(viewController, animated: false)
            }
        }
            
    }
}
