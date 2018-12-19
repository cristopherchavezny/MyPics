//
//  ViewController.swift
//  MyPics
//
//  Created by Cris C on 12/14/18.
//  Copyright © 2018 Hazlo Tech. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PhotoAccessDelegate {
    lazy var photoAccessManager: PhotoAccessManager? = {
        [weak self] in
        let photoAccessManager = PhotoAccessManager()
        photoAccessManager.photoAccessDelegate = self

        return photoAccessManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func ShowPhotoLibrary(_ sender: UIButton) {
        photoAccessManager?.openPhotoLibrary()
    }

    func presentPhotoLibraryUsing(pickerController: UICollectionViewController) {
        self.show(pickerController, sender: self)
    }

    func presentAlert(alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }
}

