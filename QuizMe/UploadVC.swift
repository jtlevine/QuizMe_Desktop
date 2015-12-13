//
//  UploadVC.swift
//  testuplaod
//
//  Created by Timothy Redband on 12/10/15.
//  Copyright © 2015 Timothy Redband. All rights reserved.
//

import Cocoa

class UploadVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource{

   
   
    @IBOutlet weak var filecorrectlabel: NSTextField!
    @IBOutlet weak var fileNAME: NSTextField!
    @IBOutlet weak var createButton: NSButton!
    @IBAction func createbutton(sender: AnyObject) {
    }
    var user_file: String = ""
    var questions = [String]()
    var answers = [String]()
    @IBAction func fileSelect(sender: NSButton) {
        let myFileDialog = NSOpenPanel()
        myFileDialog.canChooseFiles = true
        myFileDialog.allowsMultipleSelection = false
        myFileDialog.beginWithCompletionHandler {(result) -> Void in
            if result == NSFileHandlingPanelOKButton{
                self.user_file = (myFileDialog.URL?.path)!
                self.fileNAME.stringValue = self.user_file
            }
        }

    }
    
    @IBAction func generateQuestions(sender: NSButton) {
        questions.removeAll()
        answers.removeAll()
        scrollView.hidden = true
        var success = true
        let check_path = NSFileManager.defaultManager()
        if check_path.fileExistsAtPath(user_file){
            let text = try! String(contentsOfFile: user_file, encoding: NSUTF8StringEncoding)
            var separation : [String] = text.componentsSeparatedByString("\n")
            var i = 0
            let white = NSCharacterSet.whitespaceCharacterSet()
            while (i < separation.count){
                separation[i] = separation[i].stringByTrimmingCharactersInSet(white)
                i++
            }
            i = 0
            var alert_called = false
            var question_found = 0
            var answer_found = 0
            let question_set = NSCharacterSet(charactersInString: "#Q:")
            let answer_set = NSCharacterSet(charactersInString: "#A:")
            let white_and_newline_set = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            while(i < separation.count){
                let temp = separation[i]
                var temp_answer: String = ""
                var temp_question: String = ""
                if temp.rangeOfString("#Q:") != nil{
                    if(question_found != answer_found){
                        call_alert()
                        success = false
                        alert_called = true
                        break
                    }
                    temp_question = temp.stringByTrimmingCharactersInSet(question_set)
                    temp_question = temp_question.stringByTrimmingCharactersInSet(white_and_newline_set)
                    questions.append(temp_question)
                    question_found++
                } else if (temp.rangeOfString("#A:") != nil){
                    if(question_found < answer_found){
                        call_alert()
                        alert_called = true
                        success = false
                        break
                    }
                    temp_answer = temp.stringByTrimmingCharactersInSet(answer_set)
                    temp_answer = temp_answer.stringByTrimmingCharactersInSet(white_and_newline_set)
                    answers.append(temp_answer)
                    answer_found++
                }
//                else if(question_found == answer_found && question_found != 0){
//                        let temp_add = temp.stringByTrimmingCharactersInSet(white_and_newline_set)
//                        answers[answer_found - 1].appendContentsOf(temp_add)
//                } else if(question_found > answer_found){
//                        let temp_add = temp.stringByTrimmingCharactersInSet(white_and_newline_set)
//                        questions[question_found - 1].appendContentsOf(temp_add)
//                }
                
                i++
            }
            print (questions)
            print(answers)
            print("-------------")
            if(question_found != answer_found && !alert_called){
                call_alert()
                success = false
            }
            if(question_found == 0){
                call_alert()
                success = false
            }
         
            
        } else{
            success = false
        }
        
        if (success){
            createButton.hidden = false
            filecorrectlabel.hidden = false
        }
        
        
    }
    
    @IBOutlet weak var tableView: NSTableView!
    
    func call_alert(){
        let alert = NSAlert()
        alert.messageText = "Warning"
        alert.addButtonWithTitle("OK")
        alert.informativeText = "There are problems with your input file. Please follow the input format!\nThe input format is:\n...\n#Q: <Question>\n#A: <Answer>\n..."
        let res = alert.runModal()
        if res == NSAlertFirstButtonReturn {
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createButton.hidden = true
        filecorrectlabel.hidden = true
        scrollView.hidden = true

        // Do any additional setup after loading the view.
    }
   
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return answers.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
     
        
        // get the NSTableCellView for the column
        let result : NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        // set the string value of the text field in the NSTableCellView
        if(tableColumn!.identifier == "answer_column"){
            result.textField?.stringValue = answers[row]
        } else{
            result.textField?.stringValue = questions[row]
        }
        
        
        // return the populated NSTableCellView
        return result
        
    }
   
    @IBOutlet weak var scrollView: NSScrollView!

    @IBAction func propagate(sender: AnyObject) {
        tableView.reloadData()
        scrollView.hidden = false
    }
    
    
    

   
  
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

