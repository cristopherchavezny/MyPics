//
//  Animations.swift
//  MyPics
//
//  Created by Cris C on 1/2/19.
//  Copyright © 2019 Hazlo Tech. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    /**
     Scales the view down with an animation effect
     To undo this effect call unShrink()
     
     - parameter duration: animation duration
     */
    func shrink(duration: TimeInterval = 2.0) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
                       completion: { Void in()  }
        )
    }
    
    /**
     Scales the view to it's original size with an animation effect
     
     - parameter duration: animation duration
     */
    func unShrink(duration: TimeInterval = 2.0) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
    }
}
