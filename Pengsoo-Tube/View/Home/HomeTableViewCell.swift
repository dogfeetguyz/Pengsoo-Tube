//
//  HomeTableViewCell.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 26/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

let HomeTableViewCellID = "HomeTableViewCell"

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: InsetLabel!
    @IBOutlet weak var descriptionLabel: InsetLabel!
    @IBOutlet weak var dateLabel: InsetLabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var moreButtonTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        thumbnailImageView.image = Util.generateImageWithColor(.white)
    }

}
