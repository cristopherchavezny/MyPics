//
//  Camera.swift
//  MyPics
//
//  Created by Cris C on 1/5/19.
//  Copyright © 2019 Hazlo Tech. All rights reserved.
//

import UIKit
import AVFoundation

class Camera: NSObject, AVCapturePhotoCaptureDelegate {
    fileprivate final let captureSession: AVCaptureSession
    let cameraPreviewView: CameraPreviewView
    
    init(captureSession: AVCaptureSession = AVCaptureSession(),
         cameraPreviewView: CameraPreviewView = CameraPreviewView()) {
        self.captureSession = captureSession
        self.cameraPreviewView = cameraPreviewView
        super.init()
        
        beginConfiguration()
        addMediaOutputs()
        connectPreviewLayerToCaptureSession()
        startSession()
    }
    
    fileprivate final func beginConfiguration() {
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(for: .video)

        guard let validVideoDevice = videoDevice,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: validVideoDevice),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
    }
    
    fileprivate final func addMediaOutputs() {
        let photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
    }
    
    fileprivate final func connectPreviewLayerToCaptureSession() {
        cameraPreviewView.videoPreviewLayer.session = captureSession
    }
    
    fileprivate final func startSession() {
        captureSession.startRunning()
    }

}
