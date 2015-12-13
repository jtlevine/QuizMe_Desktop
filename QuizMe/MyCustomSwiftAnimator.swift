//
//  MyCustomSwiftAnimator.swift
//  QuizMe
//
//  Created by Josh Levine on 12/6/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class MyCustomSwiftAnimator: NSObject, NSViewControllerPresentationAnimator {
    
    func animatePresentationOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
        
        let bottomVC = fromViewController
        let topVC = viewController
        
        // make sure the view has a CA layer for smooth animation
        topVC.view.wantsLayer = true
        
        // set redraw policy
        topVC.view.layerContentsRedrawPolicy = .OnSetNeedsDisplay
        
        // start out invisible
        topVC.view.alphaValue = 0
        
        // add view of presented viewcontroller
        bottomVC.view.addSubview(topVC.view)
        
        // adjust size
        topVC.view.frame = bottomVC.view.frame
        
        // Do some CoreAnimation stuff to present view
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            
            // fade duration
            context.duration = 0
            // animate to alpha 1
            topVC.view.animator().alphaValue = 1
            
            }, completionHandler: nil)
        
    }
    
    func animateDismissalOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
        
        let bottomVC = fromViewController
        let topVC = viewController
        
        // make sure the view has a CA layer for smooth animation
        topVC.view.wantsLayer = true
        
        // set redraw policy
        topVC.view.layerContentsRedrawPolicy = .OnSetNeedsDisplay
        
        // Do some CoreAnimation stuff to present view
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            
            // fade duration
            context.duration = 0
            // animate view to alpha 0
            topVC.view.animator().alphaValue = 0
            
            }, completionHandler: {
                
                // remove view
                topVC.view.removeFromSuperview()
        })
        
    }
}
