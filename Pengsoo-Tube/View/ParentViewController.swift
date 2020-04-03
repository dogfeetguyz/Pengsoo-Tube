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
    private var isPaused: Bool = false
    private var isEnded: Bool = false
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
        
        let modal = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        modal.viewModel = playerViewModel
        modal.view.layoutIfNeeded()
        
        let miniPlayerOrigin = self.miniPlayerView.frame.origin
        let endModalOrigin = CGPoint(x: 0, y: view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
        
        self.movin!.addAnimations([
            self.tabBarViewController!.view.mvn.alpha.from(1).to(0.6),
            modal.view.mvn.point.from(miniPlayerOrigin).to(endModalOrigin),
            modal.view.mvn.cornerRadius.from(0.0).to(10.0),
//            self.miniPlayerPlayerView.mvn.size.from(self.miniPlayerLayerView.frame.size).to(modal.playerView.frame.size),
            self.tabBarViewController!.tabBar.mvn.alpha.from(1.0).to(0.0),
            ])
        
        let dismissGesture = GestureAnimating(modal.view, .bottom, modal.view.frame.size)
        dismissGesture.panCompletionThresholdRatio = 0.1
        
        let transition = Transition(self.movin!, self, modal, GestureTransitioning(.present, nil, dismissGesture))
        transition.customContainerViewSetupHandler = { [unowned self] type, containerView in
            if type.isPresenting {
                if self.isEnded {
                    Util.loadCachedImage(url: Util.getAvailableThumbnailImageUrl(currentItem: self.playerViewModel.getPlayingItem()!)) { (image) in
                        self.playerViewController?.replayButton.isHidden = false
                        self.playerViewController?.replayButton.setBackgroundImage(image, for: .normal)
                        self.playerViewController?.replayButton.layoutIfNeeded()
                        self.playerViewController?.replayButton.subviews.first?.contentMode = .scaleAspectFill
                    }
                }
                
                self.playerViewController!.setPlayerView(view: self.miniPlayerPlayerView)
                self.miniPlayerView.isHidden = true
                
                containerView.addSubview(modal.view)
                containerView.addSubview(self.tabBarViewController!.tabBar)
                modal.view.layoutIfNeeded()
                
                self.beginAppearanceTransition(false, animated: false)
                modal.beginAppearanceTransition(true, animated: false)
            } else {
                self.beginAppearanceTransition(true, animated: false)
                modal.beginAppearanceTransition(false, animated: false)
            }
        }
        
        transition.customContainerViewCompletionHandler = { [unowned self] type, didComplete, containerView in
            self.endAppearanceTransition()
            modal.endAppearanceTransition()
            
            if type.isDismissing {
                if didComplete {
                    //complete dismiss
                    self.setPlayerView()
                    modal.view.removeFromSuperview()
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
        
        self.playerViewController = modal
        modal.modalPresentationStyle = .overCurrentContext
        modal.transitioningDelegate = self.movin!.configureCustomTransition(transition)
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

            if let modalViewController = self.playerViewController {
                modalViewController.updatePlayerUI()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.present(modalViewController, animated: true, completion: nil)

                    let index = self.playerViewModel.getPlayingIndex()
                    if (index >= 0 && index <= self.playerViewModel.getQueueItems().count-1) {
                        DispatchQueue.main.async() {
                            modalViewController.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
                        }
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

                if self.isPresented {
                    if let modalViewController = self.playerViewController {
                        modalViewController.updatePlayerUI()
                        
                        let index = self.playerViewModel.getPlayingIndex()
                        if (index >= 0 && index <= self.playerViewModel.getQueueItems().count-1) {
                            modalViewController.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
                        }
                    }
                } else {
                    self.openPlayer()
                }

                DispatchQueue.main.async() {
                    self.miniPlayerTitle.text = currentItem.videoTitle
                    let playerVars: [String: Any] = [
                        "autoplay": 1,
                        "controls": 1,
                        "cc_load_policy": 0,
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
    
// MARK: - BUTTON ACTION
    @IBAction func miniplayerButtonAction(_ sender: Any) {
        openPlayer()
    }
    
    @IBAction func pauseButtonAction(_ sender: Any) {
        if isPaused {
            isPaused = false
            if isEnded {
                miniPlayerPlayerView.seek(to: 0, allowSeekAhead: true)
            }
            miniPlayerPlayerView.play()
            miniPlayerPauseButton.setImage(Image(systemName: "pause.fill"), for: .normal)
        } else {
            isPaused = true
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
        print("Ready")
        playerView.fetchPlayerState { (state) in
            print("Fetch Player State: \(state)")
        }
    }
    
    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState) {
        if state == .ended {
            isEnded = true
            Util.loadCachedImage(url: Util.getAvailableThumbnailImageUrl(currentItem: playerViewModel.getPlayingItem()!)) { (image) in
                self.playerViewController?.replayButton.isHidden = false
                self.playerViewController?.replayButton.setBackgroundImage(image, for: .normal)
                self.playerViewController?.replayButton.layoutIfNeeded()
                self.playerViewController?.replayButton.subviews.first?.contentMode = .scaleAspectFill
                
                self.miniPlayerReplayButton.isHidden = false
                self.miniPlayerReplayButton.setBackgroundImage(image, for: .normal)
                self.miniPlayerReplayButton.layoutIfNeeded()
                self.miniPlayerReplayButton.subviews.first?.contentMode = .scaleAspectFill

                self.miniPlayerPauseButton.setImage(Image(systemName: "play.fill"), for: .normal)
                self.isPaused = true
            }
        } else if state == .playing {
            isEnded = false
            
            if isPaused {
                isPaused = false
                miniPlayerPlayerView.play()
                miniPlayerPauseButton.setImage(Image(systemName: "pause.fill"), for: .normal)
            }
            
            if playerViewController?.replayButton.isHidden == false {
                playerViewController?.replayButton.isHidden = true
            }
            
            if miniPlayerReplayButton.isHidden == false {
                miniPlayerReplayButton.isHidden = true
            }
        } else if state == .paused {
            isPaused = true
            miniPlayerPauseButton.setImage(Image(systemName: "play.fill"), for: .normal)
        } else {
            print("Player State: \(state)")
        }
    }
    
    func playerView(_ playerView: YoutubePlayerView, didChangeToQuality quality: YoutubePlaybackQuality) {
    }
    
    func playerView(_ playerView: YoutubePlayerView, receivedError error: Error) {
    }
    
    func playerView(_ playerView: YoutubePlayerView, didPlayTime time: Float) {
    }
    
    func playerViewPreferredBackgroundColor(_ playerView: YoutubePlayerView) -> UIColor {
        return .clear
    }
}
