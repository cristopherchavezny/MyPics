//
//  Alerts.swift
//  MyPics
//
//  Created by Cris C on 12/14/18.
//  Copyright © 2018 Hazlo Tech. All rights reserved.
//

import UIKit

class PhotosPermissionAlerts {
    private final let authorizationStatus: AuthorizationStatus
    private final let tittle = "Photo Library Access"
    private final var message = ""
    
    private final lazy var deniedPhotoLibraryAlertText: String = {
        return """
    You've denied access to your photo library. \n
    To use this feature we need access to your photos. Your photos will always be yours.
    """
    }()

    private final lazy var restrictedPhotoLibraryAlertText: String = {
        return """
    Your account has restrictions. \
    Your account can not grant access to the device's photo library.
    """
    }()
    
    private final lazy var deniedCameraAlertText: String = {
        return """
    You've denied access to your camera. \n
    To use this feature we need access to your camera.
    """
    }()
    
    private final lazy var restrictedCameraAlertText: String = {
        return """
    Your account has restrictions. \
    Your account can not grant access to the device's camera.
    """
    }()
    
    private final var settingsActionText: String?
    
    init(authorizationType: AuthorizationType, authorizationStatus: AuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
        configureAlertPropertiesUsing(authorizationType: authorizationType, authorizationStatus: authorizationStatus)
    }
    
    func configureAlertPropertiesUsing(authorizationType: AuthorizationType, authorizationStatus: AuthorizationStatus) {
        switch authorizationStatus {
        case .Denied:
            message =  authorizationType == .Camera ? deniedCameraAlertText : deniedPhotoLibraryAlertText
            settingsActionText = "Settings"
        case .Restricted:
            message = authorizationType == .Camera ? restrictedCameraAlertText : restrictedPhotoLibraryAlertText
        default: break;
        }
    }
    
    func createAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: tittle, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        if let settingsActionText = settingsActionText {
            let settingsAction = UIAlertAction(title: settingsActionText, style: .default) { (UIAlertAction) in
                if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(settingsAction)
        }
        alertController.addAction(okayAction)
        
        return alertController
    }
}

