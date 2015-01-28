//
//  ZoomPresentAnimationController.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 27..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class ZoomPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.view.frame = finalFrame
        toViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01)
        
        let containerView = transitionContext.containerView()
        containerView.addSubview(toViewController.view)
        
        let animationDuration = self .transitionDuration(transitionContext)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        UIView.animateWithDuration(animationDuration, animations: {
            toViewController.view.transform = CGAffineTransformIdentity
            fromViewController.view.transform = CGAffineTransformMakeScale(2, 2)
            fromViewController.view.alpha = 0.5
        }) { finished in
            fromViewController.view.transform = CGAffineTransformIdentity;
            fromViewController.view.alpha = 1.0;

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}