//
//  ButtonPresentAnimationController.swift
//  MyPics
//
//  Created by Cris C on 12/29/18.
//  Copyright © 2018 Hazlo Tech. All rights reserved.
//

import UIKit

class ButtonPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let originFrame: CGRect
    private let photoType: String
    
    init(originFrame: CGRect, photoType: String) {
        self.originFrame = originFrame
        self.photoType = photoType
    }
    
    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let _ = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let snapshot = toViewController.view.snapshotView(afterScreenUpdates: true)
            else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        let buttonColoredView = UIView(frame: originFrame)
        buttonColoredView.backgroundColor = UIColor(red: 28/255, green: 25/255, blue: 76/255, alpha: 1.0)
        
        let backgroundColoredView = UIView(frame: originFrame)
        backgroundColoredView.backgroundColor = UIColor(red: 4/255, green: 3/255, blue: 29/255, alpha: 1.0)
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(backgroundColoredView)
        containerView.addSubview(snapshot)
        containerView.addSubview(buttonColoredView)
        
        snapshot.frame = originFrame
        snapshot.layer.opacity = 0.0
        toViewController.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)

        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeLinear,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1, animations: {
                    buttonColoredView.layer.opacity = 0.0
                    buttonColoredView.frame = finalFrame

                    snapshot.layer.opacity = 1.0
                    snapshot.frame = finalFrame
                })
        }) { animationEnded in
            toViewController.view.isHidden = false
            buttonColoredView.removeFromSuperview()
            backgroundColoredView.removeFromSuperview()
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    
    
}
