//
//  MemeViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 13/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController {

    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var pengsooVideosButton: UIButton!
    @IBOutlet weak var pengsooVideosBgImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let headerUrl = Util.getHeaderUrl() {
            if headerUrl.count > 0 {
                Util.loadCachedImage(url: headerUrl) { (image) in
                    self.pengsooVideosBgImageView!.image = image
                }
            }
        }
    }
    
    @IBAction func photoLibraryButtonAction(_ sender: Any) {
    }
    
    @IBAction func pengsooVideosButtonAction(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
