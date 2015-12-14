//
//  SelectedCellVC.swift
//  QuizMe
//
//  Created by Josh Levine on 12/11/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class SelectedCellVC: NSViewController {

    var question = Question()
    var questionTemp = ""
    var answerTemp = ""
    var state = "q"
    var inSet : BoolWrapper?
    var set : QmSet?
    
    @IBOutlet weak var btFlip: NSButton!
    @IBOutlet weak var btBack: NSButton!
    @IBOutlet weak var btSaveChanges: NSButton!
    @IBOutlet weak var lbLabel: NSTextField!
    @IBOutlet weak var tvText: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTemp = question.qText
        answerTemp = question.aText
        tvText.stringValue = question.qText
    }
    
    @IBAction func btFlip_onClick(sender: NSButton) {
        if state == "q"{
            questionTemp = tvText.stringValue
            tvText.stringValue = question.aText
            state = "a"
            lbLabel.stringValue = "Answer:"
        }
        else{
            answerTemp = tvText.stringValue
            tvText.stringValue = question.qText
            state = "q"
            lbLabel.stringValue = "Question:"
        }
    }
    
    @IBAction func btBack_onClick(sender: NSButton) {
        if(inSet?.value == true){
            let vc : SelectedSetCellVC = (self.storyboard?.instantiateControllerWithIdentifier("SelectedSetCell"))! as! SelectedSetCellVC
            vc.set = set
            self.view.window?.contentViewController = vc
        }
        else{
            let vc : NSViewController = (self.storyboard?.instantiateControllerWithIdentifier("Recents"))! as! NSViewController
            self.view.window?.contentViewController = vc
        }
    }
}
