//
//  SelectedCellVC.swift
//  QuizMe
//
//  Created by Josh Levine on 12/11/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class SelectedCellVC: NSViewController {

    @IBOutlet weak var btFlip: NSButton!
    @IBOutlet weak var btBack: NSButton!
    @IBOutlet weak var btSaveChanges: NSButton!
    @IBOutlet weak var lbLabel: NSTextField!
    @IBOutlet weak var tvText: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
