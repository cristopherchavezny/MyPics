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
    Your account can not grant access to the device photo library.
    """
    }()
    
    private final var settingsActionText: String?
    
    init(authorizationStatus: AuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
        configureAlertPropertiesUsing(authorizationStatus: self.authorizationStatus)
    }
    
    func configureAlertPropertiesUsing(authorizationStatus: AuthorizationStatus) {
        switch authorizationStatus {
        case .Denied:
            message =  deniedPhotoLibraryAlertText
            settingsActionText = "Settings"
        case .Restricted:
            message = restrictedPhotoLibraryAlertText
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

