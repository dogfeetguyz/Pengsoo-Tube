//
//  ParentViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 26/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import Movin
import AlamofireImage

class ParentViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var miniPlayerTitle: UILabel!
    @IBOutlet weak var miniPlayerCloseButton: UIButton!
    @IBOutlet weak var miniPlayerPauseButton: UIButton!
    @IBOutlet weak var miniPlayerReplayButton: UIButton!
    @IBOutlet weak var miniPlayerLayerView: UIView!
    @IBOutlet weak var miniPlayerPlayerView: YoutubePlayerView!
    @IBOutlet weak var miniplayerBottomConstraint: NSLayoutConstraint!
    
    var tabBarViewController: UITabBarController?
    
    internal var playerViewController: PlayerViewController?
    private var movin: Movin?
    private var isPresented: Bool = false
    private var currentTabIndex: Int = 0
    
    var playerViewModel = PlayerViewModel()
    
// MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miniPlayerPlayerView.backgroundColor = .clear
        
        miniPlayerView.layer.shadowColor = UIColor.label.cgColor
        miniPlayerView.layer.shadowOpacity = 0.1
        miniPlayerView.layer.shadowOffset = CGSize(width: 0, height: -10)
        miniPlayerView.layer.shadowRadius = 5
        miniPlayerView.layer.masksToBounds = false
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.1)
        self.miniPlayerCloseButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        self.miniPlayerPauseButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onVideoPlay(_:)), name: AppConstants.notification_show_miniplayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ovVideoPlayInQueue(_:)), name: AppConstants.notification_play_quque, object: nil)
        miniplayerBottomConstraint.constant = tabBarViewController!.tabBar.frame.height
        self.miniPlayerView.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TabBarControllerSegue" {
            if let vc = segue.destination as? UITabBarController {
                self.tabBarViewController = vc
                self.tabBarViewController?.delegate = self
            }
        }
    }
        
// MARK: - ANIMATION
    private func setupAnimation() {
        if self.movin != nil { return }
        
        self.movin = Movin(1.0, TimingCurve(curve: .easeInOut, dampingRatio: 0.8))
        
        let player = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        player.viewModel = playerViewModel
        player.setupConstraints(statusBarHeight: view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0, parentWidth: self.view.frame.width)
        
        let miniPlayerOrigin = self.miniPlayerView.frame.origin
        let endModalOrigin = CGPoint(x: 0, y: view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
        
        self.movin!.addAnimations([
            self.tabBarViewController!.view.mvn.alpha.from(1).to(0.6),
            player.view.mvn.point.from(miniPlayerOrigin).to(endModalOrigin),
            player.view.mvn.cornerRadius.from(0.0).to(10.0),
//            self.miniPlayerPlayerView.mvn.size.from(self.miniPlayerLayerView.frame.size).to(modal.playerView.frame.size),
            self.tabBarViewController!.tabBar.mvn.alpha.from(1.0).to(0.0),
            ])
        
        let dismissGesture = GestureAnimating(player.view, .bottom, player.view.frame.size)
        dismissGesture.panCompletionThresholdRatio = 0.1
        
        let transition = Transition(self.movin!, self, player, GestureTransitioning(.present, nil, dismissGesture))
        transition.customContainerViewSetupHandler = { [unowned self] type, containerView in
            if type.isPresenting {
                if self.playerViewModel.isEnded {
                    Util.loadCachedImage(url: Util.getAvailableThumbnailImageUrl(currentItem: self.playerViewModel.getPlayingItem()!)) { (image) in
                        player.setEndingUI(isHidden: false, image: image)
                    }
                }
                
                player.setPlayerView(view: self.miniPlayerPlayerView)
                self.miniPlayerView.isHidden = true
                
                containerView.addSubview(player.view)
                containerView.addSubview(self.tabBarViewController!.tabBar)
                
                self.beginAppearanceTransition(false, animated: false)
                player.beginAppearanceTransition(true, animated: false)
            } else {
                self.beginAppearanceTransition(true, animated: false)
                player.beginAppearanceTransition(false, animated: false)
            }
        }
        
        transition.customContainerViewCompletionHandler = { [unowned self] type, didComplete, containerView in
            self.endAppearanceTransition()
            player.endAppearanceTransition()
            
            if type.isDismissing {
                if didComplete {
                    //complete dismiss
                    self.setPlayerView()
                    player.view.removeFromSuperview()
                    self.tabBarViewController?.tabBar.removeFromSuperview()
                    self.tabBarViewController?.view.addSubview(self.tabBarViewController!.tabBar)
                    self.tabBarViewController?.tabBar.alpha = 1.0
                    self.tabBarViewController!.view.alpha = 1.0
                    
                    self.miniPlayerView.isHidden = false
                    self.isPresented = false
                    self.movin = nil
                    self.playerViewController = nil
                    
                    self.setupAnimation()
                } else {
                    //cancel dismiss
                }
            } else {
                if didComplete {
                    //complete present
                    self.playerViewController!.youtubeView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
                } else {
                    //cancel present
                }
            }
        }
        
        self.playerViewController = player
        player.modalPresentationStyle = .overCurrentContext
        player.transitioningDelegate = self.movin!.configureCustomTransition(transition)
    }
    
// MARK:- PLAYER FUNCTION
    func setPlayerView() {
        self.miniPlayerPlayerView.frame = self.miniPlayerLayerView.bounds
        self.miniPlayerLayerView.addSubview(self.miniPlayerPlayerView)
    }
    
    func openPlayer() {
        if !self.isPresented {
            self.isPresented = true

            setupAnimation()
            miniPlayerPlayerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)

            if let player = self.playerViewController {
                player.updatePlayerUI()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.present(player, animated: true, completion: nil)

                    DispatchQueue.main.async() {
                        player.scrollToNowPlaying(animated: false)
                    }
                })
            }
        }
    }
    
    @objc func onVideoPlay(_ notification: Notification) {
        self.miniPlayerPlayerView.stop()
        self.miniPlayerPlayerView.load(URLRequest(url: URL(string:"about:blank")!))
        
        self.playerViewModel.replaceQueue(videoItems: notification.userInfo![AppConstants.notification_userInfo_video_items] as! [VideoItemModel],
                                     playingIndex: notification.userInfo![AppConstants.notification_userInfo_playing_index] as! Int)
        
        if let currentItem = self.playerViewModel.getPlayingItem() {
            self.playerViewModel.addToRecent(item: currentItem)
            self.openPlayer()

            // load video asynchronosly because of openPlayer()
            DispatchQueue.main.async() {
                self.miniPlayerTitle.text = currentItem.videoTitle
                let playerVars: [String: Any] = [
                    "autoplay": 1,
                    "controls": 0,
                    "modestbranding": 1,
                    "playsinline": 1,
                    "rel": 0,
                    "origin": "https://youtube.com"
                ]
                self.miniPlayerPlayerView.delegate = self
                self.miniPlayerPlayerView.loadWithVideoId(currentItem.videoId, with: playerVars)
            }
        } else {
            //error message please
        }
    }
    
    @objc func ovVideoPlayInQueue(_ notification: Notification) {
        self.miniPlayerPlayerView.stop()
        self.miniPlayerPlayerView.load(URLRequest(url: URL(string:"about:blank")!))
        
        self.playerViewModel.setPlayingIndex(index: notification.userInfo![AppConstants.notification_userInfo_playing_index] as! Int)
        
        if let currentItem = self.playerViewModel.getPlayingItem() {
            self.playerViewModel.addToRecent(item: currentItem)

            if let player = self.playerViewController {
                player.updatePlayerUI()
                player.scrollToNowPlaying(animated: true)
            }
            
            self.miniPlayerTitle.text = currentItem.videoTitle
            let playerVars: [String: Any] = [
                "autoplay": 1,
                "controls": 0,
                "modestbranding": 1,
                "playsinline": 1,
                "rel": 0,
                "origin": "https://youtube.com"
            ]
            self.miniPlayerPlayerView.delegate = self
            self.miniPlayerPlayerView.loadWithVideoId(currentItem.videoId, with: playerVars)
        } else {
            //error message please
        }
    }
    
    
// MARK: - BUTTON ACTION
    @IBAction func miniplayerButtonAction(_ sender: Any) {
        openPlayer()
    }
    
    @IBAction func pauseButtonAction(_ sender: Any) {
        if playerViewModel.isPaused {
            playerViewModel.isPaused = false
            if playerViewModel.isEnded {
                miniPlayerPlayerView.seek(to: 0, allowSeekAhead: true)
            }
            miniPlayerPlayerView.play()
            miniPlayerPauseButton.setImage(Image(systemName: "pause.fill"), for: .normal)
        } else {
            playerViewModel.isPaused = true
            miniPlayerPlayerView.pause()
            miniPlayerPauseButton.setImage(Image(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        miniPlayerView.isHidden = true
        miniPlayerPlayerView.pause()
    }
    
    @IBAction func replayButtonAction(_ sender: Any) {
        miniPlayerPlayerView.seek(to: 0, allowSeekAhead: true)
        miniPlayerPlayerView.play()
    }
}

// MARK: - UITabBarControllerDelegate
extension ParentViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if currentTabIndex == tabBarController.selectedIndex {
            if let viewController = tabBarController.viewControllers![currentTabIndex] as? HomeViewController {
                viewController.scrollToTop()
            } else if let navigationController = tabBarController.viewControllers![currentTabIndex] as? UINavigationController {
                if let viewController = navigationController.topViewController as? LibraryViewController {
                    viewController.scrollToTop()
                }
            }
        } else {
            currentTabIndex = tabBarController.selectedIndex
        }
    }
}

// MARK: - YoutubePlayerViewDelegate
extension ParentViewController: YoutubePlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {
        
        playerView.fetchDuration { (duration) in
            self.playerViewModel.setDuration(duration: duration!)
            if let player = self.playerViewController {
                player.updateDuration()
            }
        }
        
        playerView.fetchPlayerState { (state) in
            print("Fetch Player State: \(state)")
        }
    }
    
    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState) {
        if state == .ended {
            if UserDefaults.standard.bool(forKey: AppConstants.key_user_default_autoplay) {
                if UserDefaults.standard.bool(forKey: AppConstants.key_user_default_repeat_one) {
                    let currentIndex = playerViewModel.getPlayingIndex()
                    Util.playQueue(at: currentIndex)
                } else {
                    let currentIndex = playerViewModel.getPlayingIndex()
                    let queueCount = playerViewModel.getQueueItems().count
                    let nextIndex = (currentIndex + 1) % queueCount
                    
                    Util.playQueue(at: nextIndex)
                }
            } else {
                playerViewModel.isEnded = true

                if let player = self.playerViewController {
                    player.updateProgress(playTime: playerViewModel.getDuration())
                    player.updatePlayButton()
                }
                    
                Util.loadCachedImage(url: Util.getAvailableThumbnailImageUrl(currentItem: playerViewModel.getPlayingItem()!)) { (image) in

                    if let player = self.playerViewController {
                        player.setEndingUI(isHidden: false, image: image)
                    }
                    
                    self.miniPlayerReplayButton.isHidden = false
                    self.miniPlayerReplayButton.setBackgroundImage(image, for: .normal)
                    self.miniPlayerReplayButton.layoutIfNeeded()
                    self.miniPlayerReplayButton.subviews.first?.contentMode = .scaleAspectFill

                    self.miniPlayerPauseButton.setImage(Image(systemName: "play.fill"), for: .normal)
                    self.playerViewModel.isPaused = true
                }
            }
        } else if state == .playing {
            playerViewModel.isEnded = false
            
            if playerViewModel.isPaused {
                playerViewModel.isPaused = false
                miniPlayerPauseButton.setImage(Image(systemName: "pause.fill"), for: .normal)
            }

            if let player = self.playerViewController {
                player.setEndingUI(isHidden: true)
                player.updatePlayButton()
            }
            
            if miniPlayerReplayButton.isHidden == false {
                miniPlayerReplayButton.isHidden = true
            }
        } else if state == .paused {
            playerViewModel.isPaused = true
            miniPlayerPauseButton.setImage(Image(systemName: "play.fill"), for: .normal)
            
            if let player = self.playerViewController {
                player.updatePlayButton()
            }
        } else {
            print("Player State: \(state)")
        }
    }
    
    func playerView(_ playerView: YoutubePlayerView, didChangeToQuality quality: YoutubePlaybackQuality) {
    }
    
    func playerView(_ playerView: YoutubePlayerView, receivedError error: Error) {
    }
    
    func playerView(_ playerView: YoutubePlayerView, didPlayTime time: Float) {
        if let player = self.playerViewController {
            player.updateProgress(playTime: time)
        }
    }
    
    func playerViewPreferredBackgroundColor(_ playerView: YoutubePlayerView) -> UIColor {
        return .clear
    }
}
