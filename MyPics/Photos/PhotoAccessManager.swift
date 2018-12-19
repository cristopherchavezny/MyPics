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
    func presentPhotoLibraryUsing(pickerController: UICollectionViewController)
    func presentAlert(alertController: UIAlertController)
}

class PhotoAccessManager {
    private final let permissions = Permissions()
    weak var photoAccessDelegate: PhotoAccessDelegate? = nil
    
    final func openPhotoLibrary() {
        permissions.authorizationStatusFor(authorizationType: .PhotoLibrary) {
            [weak self] authorizationStatus in
            switch authorizationStatus {
            case .Authorized:
                DispatchQueue.main.async {
                    self?.showPhotoLibrary()                    
                }
            case .Denied:
                self?.showAlertforPhotoLibrary(authorizationStatus: .Denied)
            case.Restricted:
                self?.showAlertforPhotoLibrary(authorizationStatus: .Restricted)
            }
        }
    }
    
    private final func showPhotoLibrary(){
        let layout = UICollectionViewFlowLayout()
        let customPhotoPicker = PhotoPickerCollectionViewController(collectionViewLayout: layout)
        photoAccessDelegate?.presentPhotoLibraryUsing(pickerController: customPhotoPicker)
    }
    
    private final func showAlertforPhotoLibrary(authorizationStatus: AuthorizationStatus) {
        let alerts = PhotosPermissionAlerts(authorizationStatus: authorizationStatus)
        let alertController = alerts.createAlertController()
        photoAccessDelegate?.presentAlert(alertController: alertController)
    }
}

