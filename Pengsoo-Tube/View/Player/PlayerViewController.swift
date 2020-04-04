//
//  PlayerViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 26/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import Movin

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var replayButton: UIButton!
    
    @IBOutlet weak var contentStack: UIStackView!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!
    @IBOutlet weak var fullscreenButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: InsetLabel!
    @IBOutlet weak var detailButton: UIButton!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressBar: UISlider!
    
    @IBOutlet weak var autoplaySwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerBottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewBttomConstraint: NSLayoutConstraint!
    
    private var isSliding = false
    
    weak var youtubeView: YoutubePlayerView!
    var viewModel: PlayerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupConstraints(statusBarHeight: CGFloat, parentWidth: CGFloat) {
        view.layoutIfNeeded()
        contentViewBttomConstraint.constant = statusBarHeight
        
        let blackScreenHeight = parentWidth * (2/16.0)
        topConstraint.constant = -blackScreenHeight
        playerBottomHeightConstraint.constant = blackScreenHeight
    }
    
    func setEndingUI(isHidden: Bool, image: UIImage? = nil) {
        if isHidden {
            replayButton.isHidden = isHidden
        } else {
            replayButton.isHidden = isHidden
            replayButton.setBackgroundImage(image, for: .normal)
            replayButton.layoutIfNeeded()
            replayButton.subviews.first?.contentMode = .scaleAspectFill
        }
    }
    
    func setPlayerView(view: YoutubePlayerView) {
        self.youtubeView = view
        self.youtubeView.frame = self.playerView.bounds
        self.playerView.insertSubview(self.youtubeView, belowSubview: self.replayButton)
        
        updateDuration()
        updateProgress()
    }
    
    func updatePlayerUI() {
        
        if youtubeView != nil {
            youtubeView.frame = playerView.bounds
        }
        if let playingItem = viewModel?.getPlayingItem() {
            titleLabel.text = playingItem.videoTitle
            detailLabel.text = "\n" + playingItem.videoDescription + "\n"
            detailLabel.contentInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.1)
        detailButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        
        shareButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        youtubeButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        fullscreenButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        
        backwardButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        forwardButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        playButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        updatePlayButton()
        
        progressBar.setThumbImage(Util.makeCircleWith(size: CGSize(width: 10, height: 10), backgroundColor: UIColor.systemGray), for: .normal)
        progressBar.setThumbImage(Util.makeCircleWith(size: CGSize(width: 10, height: 10), backgroundColor: UIColor.systemGray2), for: .highlighted)
        
        repeatButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        if UserDefaults.standard.bool(forKey: AppConstants.key_user_default_repeat_one) {
            repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
        } else {
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        }
        
        if UserDefaults.standard.bool(forKey: AppConstants.key_user_default_autoplay) {
            autoplaySwitch.isOn = true
            repeatButton.isEnabled = true
        } else {
            autoplaySwitch.isOn = false
            repeatButton.isEnabled = false
        }
        
        tableView.reloadData()
    }
    
    func updatePlayButton() {
        
        if viewModel!.isPaused || viewModel!.isEnded {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    func updateDuration() {
        let duration = viewModel?.getDuration()
        if duration! >= 3600.0 {
            let hour = Int(duration! / 3600.0)
            let min = (Int(duration!) % 3600) / 60
            let sec = (Int(duration!) % 3600) % 60

            playTimeLabel.text = "00:00:00"
            durationLabel.text = String(format: "%02d:%02d:%02d", hour, min, sec)
        } else {
            let min = Int(duration!) / 60
            let sec = Int(duration!) % 60
            
            playTimeLabel.text = "00:00"
            durationLabel.text = String(format: "%02d:%02d", min, sec)
        }
    }
    
    func updateProgress() {
        if viewModel!.isPaused {
            if youtubeView != nil {
                youtubeView.fetchCurrentTime { (playTime) in
                    self.updateProgress(playTime: Float(playTime!))
                }
            }
        }
    }
    
    func updateProgress(playTime: Float) {
        if !isSliding {
            let duration = viewModel?.getDuration()
            if duration! >= 3600.0 {
                let hour = Int(playTime / 3600.0)
                let min = (Int(playTime) % 3600) / 60
                let sec = (Int(playTime) % 3600) % 60

                playTimeLabel.text = String(format: "%20d:%02d:%02d", hour, min, sec)
            } else {
                let min = Int(playTime) / 60
                let sec = Int(playTime) % 60

                playTimeLabel.text = String(format: "%02d:%02d", min, sec)
            }
            
            progressBar.value = Float(playTime/duration!)
        }
    }
    
    func scrollToNowPlaying(animated: Bool) {
        let index = viewModel!.getPlayingIndex()
        if (index >= 0 && index <= viewModel!.getQueueItems().count-1) {
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: animated)
        }
    }
        
// MARK: - USER ACTION
    @IBAction func replayButtonAction(_ sender: Any) {
        youtubeView.seek(to: 0, allowSeekAhead: true)
        youtubeView.play()
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        if let item = viewModel?.getPlayingItem() {
            let textToShare = [ Util.generateYoutubeUrl(videoId: item.videoId), "Shared from Peng-Ha Tube" ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [.airDrop]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func youtubeButtonAction(_ sender: Any) {
        if let item = viewModel?.getPlayingItem() {
            Util.openYoutube(videoId: item.videoId)
        }
    }
    
    @IBAction func fullscreenButtonAction(_ sender: Any) {
//        if viewModel!.isFullscreen {
//            viewModel!.isFullscreen = false
//            let value = UIInterfaceOrientation.portrait.rawValue
//            UIDevice.current.setValue(value, forKey: "orientation")
//            view.frame = CGRect(x: 0, y: view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0, width: view.frame.width, height: view.frame.height)
//            view.cornerRadius = 10
//        } else {
//            viewModel!.isFullscreen = true
//            let value = UIInterfaceOrientation.landscapeRight.rawValue
//            UIDevice.current.setValue(value, forKey: "orientation")
//            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
//            view.cornerRadius = 0
//        }
    }
    
    @IBAction func detailButtonAction(_ sender: Any) {
        if detailLabel.isHidden {
            detailLabel.isHidden = false
            detailButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        } else {
            detailLabel.isHidden = true
            detailButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
    }
    
    @IBAction func repeatButtonAction(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: AppConstants.key_user_default_repeat_one) {
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
            UserDefaults.standard.set(false, forKey: AppConstants.key_user_default_repeat_one)
        } else {
            repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
            UserDefaults.standard.set(true, forKey: AppConstants.key_user_default_repeat_one)
        }
    }
    
    @IBAction func backwardButtonAction(_ sender: Any) {
        let duration = viewModel?.getDuration()
        var seekToTime = duration!*progressBar.value - 15
        
        if seekToTime <= 0 {
            seekToTime = 0
        }
        
        youtubeView.seek(to: seekToTime, allowSeekAhead: true)
        progressBar.value = Float(seekToTime/duration!)
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        let duration = viewModel?.getDuration()
        var seekToTime = duration!*progressBar.value + 15
        
        if seekToTime >= duration! {
            seekToTime = duration!
        }
        
        youtubeView.seek(to: seekToTime, allowSeekAhead: true)
        progressBar.value = Float(seekToTime/duration!)
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        if viewModel!.isPaused {
            viewModel!.isPaused = false
            if viewModel!.isEnded {
                youtubeView.seek(to: 0, allowSeekAhead: true)
            }
            youtubeView.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            viewModel!.isPaused = true
            youtubeView.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func seekAction(_ sender: Any, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                isSliding = true
            case .moved:
                let playTime = (viewModel?.getDuration())!*progressBar.value
                let duration = viewModel?.getDuration()
                if duration! >= 3600.0 {
                    let hour = Int(playTime / 3600.0)
                    let min = (Int(playTime) % 3600) / 60
                    let sec = (Int(playTime) % 3600) % 60

                    playTimeLabel.text = String(format: "%20d:%02d:%02d", hour, min, sec)
                } else {
                    let min = Int(playTime) / 60
                    let sec = Int(playTime) % 60

                    playTimeLabel.text = String(format: "%02d:%02d", min, sec)
                }
            case .ended:
                youtubeView.seek(to: (viewModel?.getDuration())!*progressBar.value, allowSeekAhead: true)
                isSliding = false
            default:
                break
            }
        }
    }
    
    @IBAction func switchAction(_ sender: Any) {
        UserDefaults.standard.set(autoplaySwitch.isOn, forKey: AppConstants.key_user_default_autoplay)
        repeatButton.isEnabled = autoplaySwitch.isOn
    }
}

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel?.getQueueItems().count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: LibraryDetailTableViewCellID, for: indexPath) as? LibraryDetailTableViewCell {
            if let playItems = viewModel?.getQueueItems() {
                let currentItem = playItems[indexPath.row]
                
                Util.loadCachedImage(url: currentItem.thumbnailMedium) { (image) in
                    cell.thumbnail.image = image
                }
                cell.titleLabel.text = currentItem.videoTitle
                cell.descriptionLabel.text = currentItem.videoDescription
                
                if indexPath.row == viewModel?.getPlayingIndex() {
                    cell.backgroundColor = .systemYellow
                } else {
                    cell.backgroundColor = .systemBackground
                    cell.alpha = 1.0
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel?.getPlayingIndex() != indexPath.row {
            Util.playQueue(at: indexPath.row)
        }
    }
}
