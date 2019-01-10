//
//  Camera.swift
//  MyPics
//
//  Created by Cris C on 1/5/19.
//  Copyright © 2019 Hazlo Tech. All rights reserved.
//

import UIKit
import AVFoundation
import  Photos

class Camera: NSObject, AVCapturePhotoCaptureDelegate {
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    fileprivate final let captureSession: AVCaptureSession
    fileprivate final let photoOutput: AVCapturePhotoOutput
    var videoDeviceInput: AVCaptureDeviceInput?
    private(set) var photoSettings: AVCapturePhotoSettings?

    lazy var context = CIContext()
    private var photoData: Data?
    private var portraitEffectsMatteData: Data?
    
    var cameraPreviewView: CameraPreviewView
    
    init(captureSession: AVCaptureSession = AVCaptureSession(),
        photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput(),
        cameraPreviewView: CameraPreviewView) {
        self.captureSession = captureSession
        self.photoOutput = photoOutput
        self.cameraPreviewView = cameraPreviewView
        super.init()
        
        beginConfiguration()
        addMediaOutputs()
        connectPreviewLayerToCaptureSession()
        startCaptureSession()
    }
    
    deinit {
        endCaptureSession()
    }
    
    fileprivate final func beginConfiguration() {
        captureSession.beginConfiguration()

        if let videoDevice = AVCaptureDevice.default(for: .video){
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            } catch {
                print("AVCaptureDeviceInput failed to initialize with videoDevice")
            }
        }

        guard let videoDeviceInput = self.videoDeviceInput,
            captureSession.canAddInput(videoDeviceInput) else { return }
        
        captureSession.addInput(videoDeviceInput)
    }
    
    fileprivate final func addMediaOutputs() {
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
    }
    
    fileprivate final func connectPreviewLayerToCaptureSession() {
        cameraPreviewView.videoPreviewLayer.session = captureSession
    }
    
    fileprivate final func startCaptureSession() {
        captureSession.startRunning()
    }
    
    fileprivate final func endCaptureSession() {
        captureSession.stopRunning()
    }
    
    func capturePhoto(with videoPreviewLayerOrientation: AVCaptureVideoOrientation) {
        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation
            }
        
            self.photoSettings = AVCapturePhotoSettings()
            guard var photoSettings = self.photoSettings else { return }
            
            // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
            if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            if let videoDeviceInput = self.videoDeviceInput, videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = .auto
            }
            
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)

        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
             self.photoData = photo.fileDataRepresentation()
        }
        // Portrait effects matte gets generated only if AVFoundation detects a face.
        if var portraitEffectsMatte = photo.portraitEffectsMatte {
            if let orientation = photo.metadata[ String(kCGImagePropertyOrientation) ] as? UInt32 {
                portraitEffectsMatte = portraitEffectsMatte.applyingExifOrientation( CGImagePropertyOrientation(rawValue: orientation)! )
            }
            let portraitEffectsMattePixelBuffer = portraitEffectsMatte.mattingImage
            let portraitEffectsMatteImage = CIImage( cvImageBuffer: portraitEffectsMattePixelBuffer, options: [ .auxiliaryPortraitEffectsMatte: true ] )
            guard let linearColorSpace = CGColorSpace(name: CGColorSpace.linearSRGB) else {
                portraitEffectsMatteData = nil
                return
            }
            portraitEffectsMatteData = context.heifRepresentation(of: portraitEffectsMatteImage, format: .RGBA8, colorSpace: linearColorSpace, options: [ CIImageRepresentationOption.portraitEffectsMatteImage: portraitEffectsMatteImage ] )
        } else {
            portraitEffectsMatteData = nil
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let photoData = photoData else {
            print("No photo data resource")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = self.photoSettings?.processedFileType.map { $0.rawValue }
                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                    
                    // Save Portrait Effects Matte to Photos Library only if it was generated
                    if let portraitEffectsMatteData = self.portraitEffectsMatteData {
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo,
                                                    data: portraitEffectsMatteData,
                                                    options: nil)
                    }
                    
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                }
                )
            }
        }
    }

}
