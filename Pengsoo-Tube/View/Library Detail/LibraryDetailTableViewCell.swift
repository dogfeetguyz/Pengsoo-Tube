//
//  LibraryDetailTableViewCell.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 1/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

let LibraryDetailTableViewCellID = "LibraryDetailTableViewCell"

class LibraryDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
