//
//  SelectedSetCellVC.swift
//  QuizMe
//
//  Created by Josh Levine on 12/13/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class SelectedSetCellVC: NSViewController {

    var questions = [Question]()
    
    @IBOutlet weak var tvTable: NSTableView!
    @IBOutlet weak var btBack: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func btBack_onClick(sender: NSButton) {
        let vc : NSViewController = (self.storyboard?.instantiateControllerWithIdentifier("Recents"))! as! NSViewController
        self.view.window?.contentViewController = vc
    }
}
