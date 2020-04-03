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
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: InsetLabel!
    @IBOutlet weak var detailButton: UIButton!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var autoplaySwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    weak var youtubeView: YoutubePlayerView!
    var viewModel: PlayerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        repeatButton.setBackgroundImage(Util.generateImageWithColor(color), for: .highlighted)
        
        if UserDefaults.standard.bool(forKey: AppConstants.key_user_default_autoplay) {
            autoplaySwitch.isOn = true
            repeatButton.isEnabled = true
        } else {
            autoplaySwitch.isOn = false
            repeatButton.isEnabled = false
        }
        
        if UserDefaults.standard.bool(forKey: AppConstants.key_user_default_repeat_one) {
            repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
        } else {
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        }
        
        tableView.reloadData()
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
