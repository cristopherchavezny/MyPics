//
//  PhotoAccessManager.swift
//  MyPics
//
//  Created by Cris C on 12/14/18.
//  Copyright © 2018 Hazlo Tech. All rights reserved.
//

import Photos
import UIKit
import Foundation

protocol PhotoAccessDelegate: class {
    func presentPicker(controller: UICollectionViewController)
    func presentCamera(previewView: UIView)
    func presentAlert(alertController: UIAlertController)
}

class PhotoAccessManager {
    private final let photoType: PhotoType?
    
    private final var selectedButtonFrame: CGRect

    private final let permissions: Permissions
    weak var photoAccessDelegate: PhotoAccessDelegate? = nil
    fileprivate final let layout: UICollectionViewFlowLayout
    
    init(photoType: PhotoType?,
         permissions: Permissions = Permissions(),
         photoAccessDelegate: PhotoAccessDelegate,
         layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout(),
         selectedButtonFrame: CGRect) {
        self.photoType = photoType
        self.permissions = permissions
        self.photoAccessDelegate = photoAccessDelegate
        self.layout = layout
        self.selectedButtonFrame = selectedButtonFrame
        
        if let photoType = self.photoType {
            showAppropriateViewBasedOnPermissionsFor(photoType: photoType)
        } else {
            showAppropriateViewBasedOnPermissionsForCamera()
        }
    }
    
    func showAppropriateViewBasedOnPermissionsFor(photoType: PhotoType) {
        permissions.authorizationStatusFor(authorizationType: .PhotoLibrary) {
            [weak self] authorizationStatus in
            switch authorizationStatus {
            case .Authorized:
                self?.showPhoto(type: photoType)
            case .Denied:
                self?.showPhotoLibraryAlert(authorizationStatus: .Denied)
            case.Restricted:
                self?.showPhotoLibraryAlert(authorizationStatus: .Restricted)
            }
        }
    }
    
    func showAppropriateViewBasedOnPermissionsForCamera() {
        permissions.authorizationStatusFor(authorizationType: .Camera) {
            [weak self] authorizationStatus in
            switch authorizationStatus {
            case .Authorized:
                self?.showCamera()
            case .Denied:
                break
            case .Restricted :
                break
            }
        }
    }
    
    fileprivate final func showPhoto(type: PhotoType){
        let photoPicker = PickerCollectionViewController(collectionViewLayout: layout, photoType: type, selectedButtonFrame: selectedButtonFrame)
        photoAccessDelegate?.presentPicker(controller: photoPicker)
    }

    fileprivate final func showPhotoLibraryAlert(authorizationStatus: AuthorizationStatus) {
        let alerts = PhotosPermissionAlerts(authorizationStatus: authorizationStatus)
        let alertController = alerts.createAlertController()
        photoAccessDelegate?.presentAlert(alertController: alertController)
    }
    
    fileprivate final func showCamera() {
        let camera = Camera()
        let cameraPreviewView = camera.cameraPreviewView
        photoAccessDelegate?.presentCamera(previewView: cameraPreviewView)
    }
    
    fileprivate final func showCameraAlert(authorizationStatus: AuthorizationStatus) {
        
    }

}
