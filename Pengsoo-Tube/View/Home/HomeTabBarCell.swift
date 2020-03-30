//
//  TabBarCollectionViewCell.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 29/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

let HomeTabBarCellID = "HomeTabBarCell"

class HomeTabBarCell: UICollectionViewCell {
    
    @IBOutlet weak var tabNameLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
