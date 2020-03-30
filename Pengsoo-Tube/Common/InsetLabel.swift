//
//  InsetLabel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 26/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit
class InsetLabel: UILabel {
    var contentInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 50)
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: contentInsets)
        super.drawText(in: insetRect)
    }
}
