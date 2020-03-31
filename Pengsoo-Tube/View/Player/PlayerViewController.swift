//
//  PlayerViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 26/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
import Movin
import YoutubePlayerView

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var replayButton: UIButton!
    weak var youtubeView: YoutubePlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setPlayerView(view: YoutubePlayerView) {
        self.youtubeView = view
        self.youtubeView.frame = self.playerView.bounds
        self.playerView.insertSubview(self.youtubeView, belowSubview: self.replayButton)
    }

    @IBAction func replayButtonAction(_ sender: Any) {
        youtubeView.seek(to: 0, allowSeekAhead: true)
        youtubeView.play()
    }
}
