//
//  CameraPreviewView.swift
//  MyPics
//
//  Created by Cris C on 1/7/19.
//  Copyright © 2019 Hazlo Tech. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
