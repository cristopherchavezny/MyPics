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
    
    fileprivate var dismissSwipeInteractionController: DismissSwipeInteractionController?
    fileprivate final let selectedButtonFrame: CGRect
    private var camera: Camera?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.transitioningDelegate = self
        dismissSwipeInteractionController = DismissSwipeInteractionController(viewController: self)
        
        self.camera = Camera(cameraPreviewView: cameraPreviewView)
        if let camera = self.camera {
            flipCameraButton.isEnabled = camera.shouldEnableFlipCameraButton
        }
    }

    init(selectedButtonFrame: CGRect) {
        self.selectedButtonFrame = selectedButtonFrame
        
        super.init(nibName: "CameraViewController", bundle: nil)
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

extension CameraViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ButtonPresentAnimationController(originFrame: selectedButtonFrame, photoType: "Camera")

    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let interactionController = dismissSwipeInteractionController else { return nil }
        return ButtonDismissAnimationController(destinationFrame: selectedButtonFrame, interactionController: interactionController)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? ButtonDismissAnimationController,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else { return nil }
        return interactionController
    }
}
