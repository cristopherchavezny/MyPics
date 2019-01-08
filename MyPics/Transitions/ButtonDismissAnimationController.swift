//
//  ButtonDismissAnimationController.swift
//  MyPics
//
//  Created by Cris C on 1/4/19.
//  Copyright © 2019 Hazlo Tech. All rights reserved.
//

import UIKit

class ButtonDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let destinationFrame: CGRect
    let interactionController: DismissSwipeInteractionController?
    
    init(destinationFrame: CGRect, interactionController: DismissSwipeInteractionController?) {
        self.destinationFrame = destinationFrame
        self.interactionController = interactionController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let snapshot = fromViewController.view.snapshotView(afterScreenUpdates: false)
            else { return }
        
        let containerView = transitionContext.containerView
        
        let buttonColoredView = UIView(frame: snapshot.frame)
        buttonColoredView.backgroundColor = UIColor(red: 28/255, green: 25/255, blue: 76/255, alpha: 1.0)
        
        containerView.insertSubview(toViewController.view, at: 0)
        containerView.addSubview(buttonColoredView)
        containerView.addSubview(snapshot)
        fromViewController.view.isHidden = true

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                buttonColoredView.frame = self.destinationFrame
                snapshot.frame = self.destinationFrame

                snapshot.layer.opacity = 0.0
                buttonColoredView.layer.opacity = 0.0
        }) { (animationEnded) in
            fromViewController.view.isHidden = false
            buttonColoredView.removeFromSuperview()
            snapshot.removeFromSuperview()
            if transitionContext.transitionWasCancelled {
                toViewController.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}
