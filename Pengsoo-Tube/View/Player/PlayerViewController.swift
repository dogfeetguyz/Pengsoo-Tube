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
    @IBOutlet weak var controllerButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    
    
    @IBOutlet weak var playerLandscapeTitleView: UIView!
    @IBOutlet weak var playerLandscapeTitleLabel: UILabel!
    @IBOutlet weak var playerLandscapeCollectionView: UICollectionView!
    @IBOutlet weak var playerControllerView: UIView!
    
    @IBOutlet weak var contentStack: UIStackView!
    
    @IBOutlet weak var shareButton: UIButton!
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
    
    @IBOutlet weak var playerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playerControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerControlBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewBttomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shareButtonWidthConstraint: NSLayoutConstraint!
    
    private var isPlayingWhenSeekStarted = false
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    weak var youtubeView: YoutubePlayerView!
    var viewModel: PlayerViewModel?

    // MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(foregroundAction), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    // MARK:- PLAYER UI
    func setupConstraints(statusBarHeight: CGFloat, parentSize: CGSize) {
        view.layoutIfNeeded()
        
        let playerHeight = parentSize.width * (13/16.0)
        let blackScreenHeight = parentSize.width * (4/16.0)
        
        playerTopConstraint.constant = -blackScreenHeight
        playerBottomConstraint.constant = parentSize.height - playerHeight
        
        playerControlHeightConstraint.constant = blackScreenHeight/2
        playerControlBottomConstraint.constant = blackScreenHeight/2
        
        contentViewTopConstraint.constant = playerHeight - blackScreenHeight/2
        contentViewBttomConstraint.constant = statusBarHeight
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
        playerView.layoutIfNeeded()
        
        self.youtubeView = view
        self.youtubeView.frame = self.playerView.bounds
        self.playerView.insertSubview(self.youtubeView, at: 0)
        
        updateDuration()
        updateProgress()
    }
    
    func updatePlayerUI() {
        
        if youtubeView != nil {
            youtubeView.frame = playerView.bounds
        }
        if let playingItem = viewModel?.getPlayingItem() {
            titleLabel.text = playingItem.videoTitle
            playerLandscapeTitleLabel.text = playingItem.videoTitle
            detailLabel.text = "\n" + playingItem.videoDescription + "\n"
            detailLabel.contentInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.1)
        detailButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        
        shareButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        fullscreenButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        
        backwardButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        forwardButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        playButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        updatePlayButton()
        
        progressBar.setThumbImage(Util.makeCircleWith(size: CGSize(width: 10, height: 10), backgroundColor: UIColor.systemGray), for: .normal)
        progressBar.setThumbImage(Util.makeCircleWith(size: CGSize(width: 10, height: 10), backgroundColor: UIColor.systemGray2), for: .highlighted)
        progressBar.value = 0
        
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
        
        if viewModel!.isFullscreen {
            playerLandscapeCollectionView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
    
    func updatePlayButton() {
        
        if viewModel!.isPaused || viewModel!.isEnded {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
            if viewModel!.isFullscreen {
                destroyPendingRequestWorkItem()
                setControllerViewsHidden(hidden: false)
            }
        } else {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)

            if viewModel!.isFullscreen {
                callPendingRequestWorkItem()
            }
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
        if viewModel!.isEnded {
            playTimeLabel.text = durationLabel.text
            progressBar.value = 1
        } else {
            if viewModel!.isPaused {
                if youtubeView != nil {
                    youtubeView.fetchCurrentTime { (playTime) in
                        if let _playTime = playTime {
                            self.updateProgress(playTime: Float(_playTime))
                        }
                    }
                }
            }
        }
    }
    
    func updateProgress(playTime: Float) {
        if viewModel!.isEnded {
            playTimeLabel.text = durationLabel.text
            progressBar.value = 1
        } else {
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
    
    func updateOrientation(isLandscape: Bool) {
        
        if isLandscape {
            viewModel!.isFullscreen = false
            destroyPendingRequestWorkItem()
            
            Util.AppUtility.lockOrientation(.portrait)
            
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
            
            let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            view.frame = CGRect(x: 0, y: statusBarHeight, width: view.frame.width, height: view.frame.height)
            view.cornerRadius = 10
            view.backgroundColor = .systemBackground
            
            shareButtonWidthConstraint!.constant = 30
            shareButton.isHidden = false
            contentStack.isHidden = false
            setControllerViewsHidden(hidden: true)
            
            let playerHeight = view.width * (13/16.0)
            let blackScreenHeight = view.width * (4/16.0)
            
            playerTopConstraint.constant = -blackScreenHeight
            playerBottomConstraint.constant = view.height - playerHeight
            
            playerControlHeightConstraint.constant = blackScreenHeight/2
            playerControlBottomConstraint.constant = blackScreenHeight/2
            
            contentViewTopConstraint.constant = playerHeight - blackScreenHeight/2
            contentViewBttomConstraint.constant = statusBarHeight
            playerView.layoutIfNeeded()
            
            youtubeView.frame = playerView.bounds
            scrollToNowPlaying(animated: false)
            tableView.reloadData()
            
            fullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
            
            NotificationCenter.default.post(name: AppConstants.notification_update_player_dismiss_gesture, object: nil, userInfo: nil)
        } else {
            viewModel!.isFullscreen = true
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            view.cornerRadius = 0
            view.backgroundColor = .black
            
            Util.AppUtility.lockOrientation(.landscapeRight)
            
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
            
            shareButtonWidthConstraint!.constant = 0
            shareButton.isHidden = true
            contentStack.isHidden = true
            callPendingRequestWorkItem()
            
            playerTopConstraint.constant = 0
            playerBottomConstraint.constant = 0
            
            playerControlHeightConstraint.constant = 60
            playerControlBottomConstraint.constant = 0
            playerView.layoutIfNeeded()
            
            youtubeView.frame = playerView.bounds
            playerLandscapeCollectionView.reloadData()
            scrollToNowPlaying(animated: false)
            
            fullscreenButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
            
            NotificationCenter.default.post(name: AppConstants.notification_update_player_dismiss_gesture, object: nil, userInfo: nil)
        }
    }
    
    func updateQueue() {
        if viewModel!.isFullscreen {
            playerLandscapeCollectionView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
    
    func scrollToNowPlaying(animated: Bool) {
        let index = viewModel!.getPlayingIndex()
        if (index >= 0 && index <= viewModel!.getQueueItems().count-1) {
            DispatchQueue.main.async {
                if self.viewModel!.isFullscreen {
                    self.playerLandscapeCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: animated)
                } else {
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: animated)
                }
            }
        }
    }
    
    // MARK:- PLAYER CONTROLLER VISIBILLITY
    func setControllerViewsHidden(hidden: Bool) {
        playerControllerView.isHidden = viewModel!.isFullscreen ? hidden : false
        playerLandscapeTitleView.isHidden = hidden
        playerLandscapeCollectionView.isHidden = (viewModel!.isPaused || viewModel!.isEnded) ? hidden : true
    }
    
    func callPendingRequestWorkItem() {
        setControllerViewsHidden(hidden: false)
        destroyPendingRequestWorkItem()
        
        pendingRequestWorkItem = DispatchWorkItem {
            if !self.viewModel!.isPaused {
                self.setControllerViewsHidden(hidden: true)
                self.pendingRequestWorkItem = nil
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: pendingRequestWorkItem!)
    }
    
    func destroyPendingRequestWorkItem() {
        if pendingRequestWorkItem != nil {
            pendingRequestWorkItem?.cancel()
            pendingRequestWorkItem = nil
        }
    }
        
    // MARK: - USER ACTION
    @IBAction func controllerButton(_ sender: Any) {
        if viewModel!.isFullscreen && !viewModel!.isPaused {
            if pendingRequestWorkItem != nil {
                destroyPendingRequestWorkItem()
                setControllerViewsHidden(hidden: true)
            } else {
                callPendingRequestWorkItem()
            }
        }
    }
    
    @IBAction func replayButtonAction(_ sender: Any) {
        youtubeView.seek(to: 0, allowSeekAhead: true)
        youtubeView.play()
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        if let item = viewModel?.getPlayingItem() {
            let alert = UIAlertController(style: .actionSheet)
                alert.addAction(title: "Cancel", style: .cancel) //.cancel action will always be at the end
                alert.addAction(image: UIImage(systemName: "play.rectangle.fill"), title: "Watch on Youtube", color: .systemRed, style: .default, isEnabled: true) { (_) in

                Util.openYoutube(videoId: item.videoId)
            }

            alert.addAction(image: UIImage(systemName: "square.and.arrow.up.on.square"), title: "Share", color: .label, style: .default, isEnabled: true) { (_) in
                let textToShare = [ Util.generateYoutubeUrl(videoId: item.videoId), "Shared from Peng-Ha Tube" ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [.airDrop]
                self.present(activityViewController, animated: true, completion: nil)
            }

            alert.addAction(image: UIImage(systemName: "t.bubble"), title: "Create Meme", color: .label, style: .default, isEnabled: true) { (_) in
                if let navigationController = UIStoryboard(name: "NewMemeFromVideosView", bundle: nil).instantiateViewController(identifier: "PickedVideoNavigationView") as? UINavigationController {
                    if let viewController = navigationController.viewControllers.first as? NewMemePickedVideoViewController {
                        viewController.videoItem = item
                        self.present(navigationController, animated: true)
                    }
                }
            }


            if viewModel!.requestType == RequestType.pengsooTv || viewModel!.requestType == RequestType.pengsooYoutube || viewModel!.requestType == RequestType.pengsooOutside {

                let homeViewModel = HomeViewModel()
                homeViewModel.delegate = self
                
                if viewModel!.requestType == RequestType.pengsooTv {
                    homeViewModel.tvListItems.append(contentsOf:(viewModel?.getQueueItems())!)
                } else if viewModel!.requestType == RequestType.pengsooYoutube {
                    homeViewModel.youtubeListItems.append(contentsOf:(viewModel?.getQueueItems())!)
                } else if viewModel!.requestType == RequestType.pengsooOutside {
                    homeViewModel.outsideListItems.append(contentsOf:(viewModel?.getQueueItems())!)
                }
                
                alert.addAction(image: UIImage(systemName: "folder.badge.plus"), title: "Add to New Playlist", color: .label, style: .default, isEnabled: true) { (_) in
                    let textFieldAlert = UIAlertController(style: .alert, title: "New Playlist", message: "Please input a name for a new playlist")

                    weak var weakTextField: TextField?
                    let textFieldConfiguration: TextField.Config = { textField in
                        textField.left(image: UIImage(systemName: "pencil.and.ellipsis.rectangle"), color: .label)
                        textField.leftViewPadding = 12
                        textField.becomeFirstResponder()
                        textField.borderWidth = 1
                        textField.cornerRadius = 8
                        textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
                        textField.backgroundColor = nil
                        textField.textColor = .label
                        textField.keyboardAppearance = .default
                        textField.keyboardType = .default
                        textField.returnKeyType = .done
                        weakTextField = textField
                    }

                    textFieldAlert.addOneTextField(configuration: textFieldConfiguration)
                    textFieldAlert.addAction(title: "Cancel", style: .cancel)
                    textFieldAlert.addAction(title: "OK", style: .default) { (_) in
                        guard let textField = weakTextField else { return }
                        homeViewModel.addtoNewPlaylist(title: textField.text!, at: self.viewModel!.playingIndex, listOf: self.viewModel!.requestType!)
                    }
                    self.present(textFieldAlert, animated: true, completion: nil)
                }

                if let playlistItems = homeViewModel.getPlaylistItems() {
                    for playlist in playlistItems {
                        alert.addAction(image: UIImage(systemName: "plus.square.on.square"), title: "Add to \(playlist.title)", color: .label, style: .default, isEnabled: true) { (_) in
                            homeViewModel.addToPlaylist(at: self.viewModel!.playingIndex, listOf: self.viewModel!.requestType!, toPlaylist: playlist)
                        }
                    }
                }
            }

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func fullscreenButtonAction(_ sender: Any) {
        updateOrientation(isLandscape: viewModel!.isFullscreen)
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
        
        updateProgress(playTime: seekToTime)
        youtubeView.seek(to: seekToTime, allowSeekAhead: true)
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        let duration = viewModel?.getDuration()
        var seekToTime = duration!*progressBar.value + 15
        
        if seekToTime >= duration! {
            seekToTime = duration!
        }
        
        updateProgress(playTime: seekToTime)
        youtubeView.seek(to: seekToTime, allowSeekAhead: true)
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
                isPlayingWhenSeekStarted = (viewModel!.isPaused != true && viewModel!.isEnded != true)
                if isPlayingWhenSeekStarted {
                    youtubeView.pause()
                }
            case .moved:
                let duration = viewModel?.getDuration()
                let playTime = duration!*progressBar.value
                
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
                
                youtubeView.seek(to: playTime, allowSeekAhead: true)
            case .ended:
                if isPlayingWhenSeekStarted {
                    youtubeView.play()
                }
            default:
                break
            }
        }
    }
    
    @IBAction func switchAction(_ sender: Any) {
        UserDefaults.standard.set(autoplaySwitch.isOn, forKey: AppConstants.key_user_default_autoplay)
        repeatButton.isEnabled = autoplaySwitch.isOn
    }
    
    @objc func foregroundAction() {
        if viewModel!.isFullscreen {
            updateOrientation(isLandscape: viewModel!.isFullscreen)
        }
    }
}


extension PlayerViewController: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        if type == .playlistUpdate {
            Util.createToast(message: message)
        }
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        if message.count > 0 {
            Util.createToast(message: message)
        }
    }
}
