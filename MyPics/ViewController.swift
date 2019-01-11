//
//  ViewController.swift
//  MyPics
//
//  Created by Cris C on 12/14/18.
//  Copyright © 2018 Hazlo Tech. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PhotoAccessDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var albumView: UIView!
    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var cameraView: UIView!
    
    var mediaAccessManager: MediaAccessManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mediaAccessManager = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if let touch = touches.first {
            switch touch.view {
            case albumView:
                albumView.shrink()
            case photosView:
                photosView.shrink()
            case cameraView:
                break
            default: break;
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if let touch = touches.first, let view = touch.view  {
            let touchLocation = touch.location(in: self.view)
            if view.frame.contains(touchLocation) {
                switch view {
                case albumView:
                     showPhotos(photoType: .Album, selectedButtonFrame: albumView.frame)
                case photosView:
                     showPhotos(photoType: .Photos, selectedButtonFrame: photosView.frame)
                    break
                case cameraView:
                     showCamera()
                default: break;
                }
            } else {
                view.unShrink()
            }
        }
    }
    
    func showCamera() {
        mediaAccessManager = MediaAccessManager(photoType: nil, photoAccessDelegate: self, selectedButtonFrame: cameraView.frame)
    }
    
    func showPhotos(photoType: PhotoType, selectedButtonFrame: CGRect) {
        mediaAccessManager = MediaAccessManager(photoType: photoType, photoAccessDelegate: self, selectedButtonFrame: selectedButtonFrame)
    }
    
    func presentPicker(controller: UICollectionViewController) {
        self.present(controller, animated: true) {
            // Upon transition animation done, all buttons return to regular size
            let _ = [
                self.albumView,
                self.photosView,
                self.cameraView
                ].map{ $0?.unShrink() }
        }
    }
    
    func presentCamera(previewView: UIView) {
        previewView.frame = view.frame
        previewView.backgroundColor = .green
        self.view.addSubview(previewView)
    }

    func presentAlert(alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentCamera(controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }
}
