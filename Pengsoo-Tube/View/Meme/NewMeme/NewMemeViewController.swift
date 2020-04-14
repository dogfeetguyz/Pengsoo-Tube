//
//  NewMemeViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 13/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

class NewMemeViewController: KUIViewController {

    var chosenImage: UIImage?
    @IBOutlet weak var chosenImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chosenImageView!.image = chosenImage!
    }
}
