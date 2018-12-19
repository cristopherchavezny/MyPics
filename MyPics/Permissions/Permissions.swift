//
//  Permissions.swift
//  MyPics
//
//  Created by Cris C on 12/14/18.
//  Copyright © 2018 Hazlo Tech. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

enum AuthorizationType: String {
    case Camera, PhotoLibrary
}

enum AuthorizationStatus: String {
    case Authorized, Denied, Restricted
}

class Permissions: NSObject {
    func authorizationStatusFor(authorizationType: AuthorizationType, completionHandler: @escaping (AuthorizationStatus) -> Void) {
        switch authorizationType {
        case .Camera:
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch cameraStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        completionHandler(.Authorized)
                    } else {
                        completionHandler(.Denied)
                    }
                }
            case .restricted:
                completionHandler(.Restricted)
            // TODO: Alert user that due to restrictions in the user account camera is not available
            case .denied:
                completionHandler(.Denied)
            // TODO: Alert user that camera access is needed
            // TODO: Give option to go to settings and make the change
            case .authorized:
                completionHandler(.Authorized)
            // TODO: Show camera
            }
            
        case .PhotoLibrary:
            let photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
            
            switch photoLibraryStatus {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == PHAuthorizationStatus.authorized{
                        completionHandler(.Authorized)
                    }
                })
            case .restricted:
                completionHandler(.Restricted)
            case .denied:
                completionHandler(.Denied)
            case .authorized:
                completionHandler(.Authorized)
            }
        }
    }
}

