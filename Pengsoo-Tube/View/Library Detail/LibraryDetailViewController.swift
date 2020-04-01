//
//  LibraryDetailViewController.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 1/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import UIKit

class LibraryDetailViewController: UIViewController {
    
    var libraryDetailType: LibraryDetailType?
    var recentItems: [Recent]?
    var playlistItem: Mylist?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if libraryDetailType == .recent {
            self.title = "Recent"
        } else {
            self.title = playlistItem?.title
        }
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = .systemYellow
        nav?.tintColor = .black
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
