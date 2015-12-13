//
//  MyCustomSwiftSegue.swift
//  QuizMe
//
//  Created by Josh Levine on 12/6/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class MyCustomSwiftSegue: NSStoryboardSegue {
    
    override func perform() {
        let animator = MyCustomSwiftAnimator()
        let sourceVC  = self.sourceController as! NSViewController
        let destVC = self.destinationController as! NSViewController
        sourceVC.presentViewController(destVC, animator: animator)
        sourceVC.view = destVC.view
    }
    
}


