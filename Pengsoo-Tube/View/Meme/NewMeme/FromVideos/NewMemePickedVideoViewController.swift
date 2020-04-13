//
//  PickedVideoViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 13/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

class NewMemePickedVideoViewController: UIViewController {
    
    var videoItem: VideoItemModel?
    
    @IBOutlet weak var youtubeView: YoutubePlayerView?
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    
    let playerViewModel = PlayerViewModel()
    var isPausedWhenSeekStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressSlider.setThumbImage(Util.makeCircleWith(size: CGSize(width: 10, height: 10), backgroundColor: UIColor.systemGray), for: .normal)
        progressSlider.setThumbImage(Util.makeCircleWith(size: CGSize(width: 10, height: 10), backgroundColor: UIColor.systemGray2), for: .highlighted)
        progressSlider.value = 0
        
        loadVideo()
    }
    
    func loadVideo() {
        title = videoItem!.videoTitle
        
        if let currentItem = videoItem {
            youtubeView?.frame = CGRect(x: 0, y: 0, width: self.view.width, height: self.view.width)
            
            DispatchQueue.main.async() {
                let playerVars: [String: Any] = [
                    "autoplay": 1,
                    "controls": 0,
                    "modestbranding": 1,
                    "playsinline": 1,
                    "rel": 0,
                    "origin": "https://youtube.com"
                ]
                self.youtubeView!.delegate = self
                self.youtubeView!.loadWithVideoId(currentItem.videoId, with: playerVars)
            }
        } else {
            Util.createToast(message: "Something went wrong. Please try again.")
        }
    }
    
    func updateProgress() {
        if playerViewModel.isEnded {
            progressSlider.value = 1
        } else {
            if playerViewModel.isPaused {
                if youtubeView != nil {
                    youtubeView!.fetchCurrentTime { (playTime) in
                        if let _playTime = playTime {
                            self.updateProgress(playTime: Float(_playTime))
                        }
                    }
                }
            }
        }
    }
    
    func updateProgress(playTime: Float) {
        if playerViewModel.isEnded {
            progressSlider.value = 1
        } else {
            let duration = playerViewModel.getDuration()
            
            progressSlider.value = Float(playTime/duration)
        }
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        if playerViewModel.isPaused {
            playerViewModel.isPaused = false
            if playerViewModel.isEnded {
                youtubeView!.seek(to: 0, allowSeekAhead: true)
            }
            youtubeView!.play()
            playButton!.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playerViewModel.isPaused = true
            youtubeView!.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func seekAction(_ sender: Any, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                isPausedWhenSeekStarted = playerViewModel.isPaused
                if !isPausedWhenSeekStarted {
                    youtubeView?.pause()
                }
            case .moved:
                let duration = playerViewModel.getDuration()
                let playTime = duration*progressSlider.value
                
                youtubeView!.seek(to: playTime, allowSeekAhead: true)
            case .ended:
                if !isPausedWhenSeekStarted {
                    youtubeView?.play()
                }
            default:
                break
            }
        }
    }
}


// MARK: - YoutubePlayerViewDelegate
extension NewMemePickedVideoViewController: YoutubePlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {
        
        playerView.fetchDuration { (duration) in
            self.playerViewModel.setDuration(duration: duration!)
        }
        
        playerView.fetchPlayerState { (state) in
            print("Fetch Player State: \(state)")
        }
    }
    
    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState) {
        if state == .ended {
            youtubeView?.seek(to: 0, allowSeekAhead: true)
        } else if state == .playing {
           playerViewModel.isEnded = false
           playerViewModel.isPaused = false
           
           playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
       } else if state == .paused {
           playerViewModel.isPaused = true
           playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
       } else {
           print("Player State: \(state)")
       }
    }
    
    func playerView(_ playerView: YoutubePlayerView, didChangeToQuality quality: YoutubePlaybackQuality) {
    }
    
    func playerView(_ playerView: YoutubePlayerView, receivedError error: Error) {
    }
    
    func playerView(_ playerView: YoutubePlayerView, didPlayTime time: Float) {
        updateProgress(playTime: time)
    }
    
    func playerViewPreferredBackgroundColor(_ playerView: YoutubePlayerView) -> UIColor {
        return .clear
    }
}
