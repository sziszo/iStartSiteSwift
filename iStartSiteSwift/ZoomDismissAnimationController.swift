//
//  ZoomDismissAnimationController.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 27..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class ZoomDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        toViewController.view.transform = CGAffineTransformMakeScale(2, 2)
        toViewController.view.alpha = 0.5
        
        let containerView = transitionContext.containerView()
        containerView.addSubview(toViewController.view)
        containerView.sendSubviewToBack(toViewController.view)
        
        let animationDuration = self .transitionDuration(transitionContext)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        
        UIView.animateWithDuration(animationDuration, animations: {
            fromViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
            toViewController.view.transform = CGAffineTransformIdentity;
            toViewController.view.alpha = 1.0;

            }) { finished in
                toViewController.view.transform = CGAffineTransformIdentity;
                toViewController.view.alpha = 1.0;
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}