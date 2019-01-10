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
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)

    private var photoData: Data?
    
    fileprivate final var cameraPreviewView: CameraPreviewView
    lazy var shouldEnableFlipCameraButton: Bool = {
       return self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
    }()
    
    fileprivate final let permissions: Permissions
    
    init(captureSession: AVCaptureSession = AVCaptureSession(),
        photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput(),
        cameraPreviewView: CameraPreviewView,
        permissions: Permissions = Permissions()) {
        self.captureSession = captureSession
        self.photoOutput = photoOutput
        self.cameraPreviewView = cameraPreviewView
        self.permissions = permissions
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

        if let videoDevice = getAvailableAVCaptureDevice() {
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
    
    //MARK: --- Flip Camera methods ---
    
    func getAvailableAVCaptureDevice() -> AVCaptureDevice? {
        let devices = videoDeviceDiscoverySession.devices
        
        if videoDeviceInput === nil { // We want the front camera since it's the first instance of Camera
            let newDevice = devices.first(where: { $0.position == .back })
            return newDevice
        } else { // determine what position the camera is in and switch
            guard let videoDeviceInput = self.videoDeviceInput else { return nil }
            
            let currentVideoDevice = videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back

            case .back:
                preferredPosition = .front
            }
            
            let newDevice = devices.first(where: { $0.position == preferredPosition})
            return newDevice
        }
    
    }
    
    func flipCamera() {
        sessionQueue.async {
            if let videoDevice = self.getAvailableAVCaptureDevice(),
                let videoDeviceInput = self.videoDeviceInput {
                do {
                    let newVideoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    self.captureSession.beginConfiguration()
                    self.captureSession.removeInput(videoDeviceInput)
                    
                    if self.captureSession.canAddInput(newVideoDeviceInput) {
                        self.captureSession.addInput(newVideoDeviceInput)
                        self.videoDeviceInput = newVideoDeviceInput
                    } else {
                        self.captureSession.addInput(videoDeviceInput)
                    }
                    self.captureSession.commitConfiguration()
                } catch {
                    print("Error occurred in flipCamera while creating video device input: \(error)")
                }
            }
        }
    }
    
    // MARK: --- Take a picture methods ---
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
        
        permissions.authorizationStatusFor(authorizationType: .PhotoLibrary) { authorizationStatus in
            switch authorizationStatus {
            case .Authorized:
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = self.photoSettings?.processedFileType.map { $0.rawValue }
                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                    
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                }
                )
            case .Denied:
                // TODO: show alert
                break
            case .Restricted:
                // TODO: Show alert
                break
            }
        }
    }

}

// MARK: --- AVCaptureDevice ---
extension AVCaptureDevice.DiscoverySession {
    /**
     The number of camera positions avialble.
     */
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions: [AVCaptureDevice.Position] = []
        
        for device in devices {
            if !uniqueDevicePositions.contains(device.position) {
                uniqueDevicePositions.append(device.position)
            }
        }
        
        return uniqueDevicePositions.count
    }
}
