//
//  ParentViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 26/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import Movin
import YoutubePlayerView
import AlamofireImage

class ParentViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var miniPlayerTitle: UILabel!
    @IBOutlet weak var miniPlayerCloseButton: UIButton!
    @IBOutlet weak var miniPlayerPauseButton: UIButton!
    @IBOutlet weak var miniPlayerReplayButton: UIButton!
    @IBOutlet weak var miniPlayerLayerView: UIView!
    @IBOutlet weak var miniPlayerPlayerView: YoutubePlayerView!
    
    internal var modalVC: PlayerViewController?
    private var movin: Movin?
    private var isPresented: Bool = false
    private var isPaused: Bool = false
    private var isEnded: Bool = false
    private var currentItem: YoutubeItemModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miniPlayerView.layer.shadowColor = UIColor.black.cgColor
        miniPlayerView.layer.shadowOpacity = 0.1
        miniPlayerView.layer.shadowOffset = CGSize(width: 0, height: -10)
        miniPlayerView.layer.shadowRadius = 5
        miniPlayerView.layer.masksToBounds = false
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.1)
        self.miniPlayerCloseButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        self.miniPlayerPauseButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onVideoPlay(_:)), name: AppConstants.notification_show_miniplayer, object: nil)
        self.setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
        
    private func setup() {
        if self.movin != nil { return }
        
        self.movin = Movin(1.0, TimingCurve(curve: .easeInOut, dampingRatio: 1.0))
        
        let modal = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        modal.view.layoutIfNeeded()
        
        let miniPlayerOrigin = self.miniPlayerView.frame.origin
        let endModalOrigin = CGPoint(x: 0, y: view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
//        let miniYoutubeFrame = miniPlayerLayerView.bounds
//        let originYoutubeFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width*(16.0/9.0))
        
        self.movin!.addAnimations([
            modal.view.mvn.point.from(miniPlayerOrigin).to(endModalOrigin),
            self.containerView.mvn.cornerRadius.from(0.0).to(10.0),
            self.containerView.mvn.alpha.from(1.0).to(0.3),
            self.tabBarController!.tabBar.mvn.point.to(CGPoint(x: 0.0, y: self.view.frame.size.height)),
            self.tabBarController!.tabBar.mvn.alpha.from(1.0).to(0.0)
//            self.miniPlayerPlayerView.mvn.frame.from(miniYoutubeFrame).to(originYoutubeFrame),
            ])
        
        let presentGesture = GestureAnimating(self.miniPlayerView, .top, self.view.frame.size)
        presentGesture.panCompletionThresholdRatio = 0.1
        let dismissGesture = GestureAnimating(modal.view, .bottom, modal.view.frame.size)
        dismissGesture.panCompletionThresholdRatio = 0.1
        
        let transition = Transition(self.movin!, self.tabBarController!, modal, GestureTransitioning(.present, presentGesture, dismissGesture))
        transition.customContainerViewSetupHandler = { [unowned self] type, containerView in
            if type.isPresenting {
                self.miniPlayerPlayerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width*(16.0/9.0))
                self.miniPlayerPlayerView.layoutIfNeeded()

                if self.isEnded {
                    Util.loadCachedImage(url: self.getThumbnailImageUrl()) { (image) in
                        self.modalVC?.replayButton.isHidden = false
                        self.modalVC?.replayButton.setBackgroundImage(image, for: .normal)
                        self.modalVC?.replayButton.layoutIfNeeded()
                        self.modalVC?.replayButton.subviews.first?.contentMode = .scaleAspectFill
                    }
                }
                modal.view.layoutIfNeeded()
                self.miniPlayerView.isHidden = true
                self.modalVC!.setPlayerView(view: self.miniPlayerPlayerView)
                
                containerView.addSubview(modal.view)
                containerView.addSubview(self.tabBarController!.tabBar)
                modal.view.layoutIfNeeded()
                self.modalVC!.setPlayerView(view: self.miniPlayerPlayerView)
                
                self.tabBarController?.beginAppearanceTransition(false, animated: false)
                modal.beginAppearanceTransition(true, animated: false)
            } else {
                self.tabBarController?.beginAppearanceTransition(true, animated: false)
                modal.beginAppearanceTransition(false, animated: false)
            }
        }
        
        transition.customContainerViewCompletionHandler = { [unowned self] type, didComplete, containerView in
            self.tabBarController?.endAppearanceTransition()
            modal.endAppearanceTransition()
            
            if type.isDismissing {
                if didComplete {
                    //complete dismiss
                    self.setPlayerView()
                    modal.view.removeFromSuperview()
                    self.tabBarController?.tabBar.removeFromSuperview()
                    self.tabBarController?.view.addSubview(self.tabBarController!.tabBar)
                    
                    self.miniPlayerView.isHidden = false
                    self.isPresented = false
                    self.movin = nil
                    self.modalVC = nil
                    
                    self.setup()
                } else {
                    //cancel dismiss
                }
            } else {
                if didComplete {
                    //complete present
                    self.miniPlayerPlayerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width*(16.0/9.0))
                    self.miniPlayerPlayerView.layoutIfNeeded()
                } else {
                    //cancel present
                    self.setPlayerView()
                    modal.view.removeFromSuperview()
                    self.tabBarController?.tabBar.removeFromSuperview()
                    self.tabBarController?.view.addSubview(self.tabBarController!.tabBar)
                    
                    self.miniPlayerView.isHidden = false
                    self.isPresented = false
                }
            }
        }
        
        self.modalVC = modal
        modal.modalPresentationStyle = .overCurrentContext
        modal.transitioningDelegate = self.movin!.configureCustomTransition(transition)
    }
    
    func getThumbnailImageUrl() -> String {
        if currentItem!.snippet.thumbnails.high.url.count > 0 {
            return currentItem!.snippet.thumbnails.high.url
        } else if currentItem!.snippet.thumbnails.medium.url.count > 0 {
            return currentItem!.snippet.thumbnails.medium.url
        } else if currentItem!.snippet.thumbnails.small.url.count > 0 {
            return currentItem!.snippet.thumbnails.small.url
        } else {
            return ""
        }
    }
    
    func setPlayerView() {
        self.miniPlayerPlayerView.frame = self.miniPlayerLayerView.bounds
        self.miniPlayerLayerView.addSubview(self.miniPlayerPlayerView)
    }
    
    func openPlayer() {
        self.miniPlayerPlayerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width*(16.0/9.0))
        self.miniPlayerPlayerView.layoutIfNeeded()
        
        guard let modalViewController = self.modalVC else { return }
        self.present(modalViewController, animated: true, completion: nil)
    }
    
    @objc func onVideoPlay(_ notification: Notification) {
        if !isPresented {
            isPresented = true
            miniPlayerPlayerView.stop()

            currentItem = notification.userInfo![AppConstants.notification_userInfo_currentPlayingItem] as? YoutubeItemModel
            miniPlayerTitle.text = currentItem!.snippet.title

            let playerVars: [String: Any] = [
                "autoplay": 1,
                "controls": 1,
                "cc_load_policy": 0,
                "modestbranding": 1,
                "playsinline": 1,
                "rel": 0,
                "origin": "https://youtube.com"
            ]
            miniPlayerPlayerView.loadWithVideoId((currentItem?.snippet.resourceId.videoId)!, with: playerVars)
            miniPlayerPlayerView.delegate = self

            openPlayer()
        }
    }
    
    @IBAction func miniplayerButtonAction(_ sender: Any) {
        if !isPresented {
            isPresented = true
            
            openPlayer()
        }
    }
    
    @IBAction func pauseButtonAction(_ sender: Any) {
        if isPaused {
            if isEnded {
                miniPlayerPlayerView.seek(to: 0, allowSeekAhead: true)
            }
            miniPlayerPlayerView.play()
            miniPlayerPauseButton.setImage(Image(systemName: "pause.fill"), for: .normal)
        } else {
            miniPlayerPlayerView.pause()
            miniPlayerPauseButton.setImage(Image(systemName: "play.fill"), for: .normal)
        }
        isPaused = !isPaused
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
            Util.loadCachedImage(url: getThumbnailImageUrl()) { (image) in
                self.modalVC?.replayButton.isHidden = false
                self.modalVC?.replayButton.setBackgroundImage(image, for: .normal)
                self.modalVC?.replayButton.layoutIfNeeded()
                self.modalVC?.replayButton.subviews.first?.contentMode = .scaleAspectFill
                
                self.miniPlayerReplayButton.isHidden = false
                self.miniPlayerReplayButton.setBackgroundImage(image, for: .normal)
                self.miniPlayerReplayButton.layoutIfNeeded()
                self.miniPlayerReplayButton.subviews.first?.contentMode = .scaleAspectFill

                self.miniPlayerPauseButton.setImage(Image(systemName: "play.fill"), for: .normal)
                self.isPaused = true
            }
        } else if state == .playing {
            isEnded = false
            if modalVC?.replayButton.isHidden == false {
                modalVC?.replayButton.isHidden = true
            }
            
            if miniPlayerReplayButton.isHidden == false {
                miniPlayerReplayButton.isHidden = true
            }
        }
    }
    
    func playerView(_ playerView: YoutubePlayerView, didChangeToQuality quality: YoutubePlaybackQuality) {
    }
    
    func playerView(_ playerView: YoutubePlayerView, receivedError error: Error) {
    }
    
    func playerView(_ playerView: YoutubePlayerView, didPlayTime time: Float) {
    }
    
    func playerViewPreferredInitialLoadingView(_ playerView: YoutubePlayerView) -> UIView? {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width*(16.0/9.0)))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        Util.loadCachedImage(url: getThumbnailImageUrl()) { (image) in
            view.image = image
        }
        
        return view
    }
}
