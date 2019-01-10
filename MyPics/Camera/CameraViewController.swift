//
//  CameraViewController.swift
//  MyPics
//
//  Created by Cris C on 1/8/19.
//  Copyright © 2019 Hazlo Tech. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    @IBOutlet weak var flipCameraButton: UIButton!
    
    private var camera: Camera?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.camera = Camera(cameraPreviewView: cameraPreviewView)
        
        if let camera = self.camera {
            flipCameraButton.isEnabled = camera.shouldEnableFlipCameraButton
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        guard let videoPreviewLayerOrientation = cameraPreviewView.videoPreviewLayer.connection?.videoOrientation else { return }
        camera?.capturePhoto(with: videoPreviewLayerOrientation)
    }
    
    @IBAction func flipCamera(_ sender: UIButton) {
        camera?.flipCamera()
    }
    
}
