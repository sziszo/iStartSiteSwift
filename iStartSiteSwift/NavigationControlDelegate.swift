//
//  NavigationControlDelegate.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 28..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {    
    
    let zoomPresentAnimationController = ZoomPresentAnimationController()
    let zoomDismissAnimationController = ZoomDismissAnimationController()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == UINavigationControllerOperation.Push {
            return zoomPresentAnimationController
        }
        
        return zoomDismissAnimationController
        
    }
    
}
