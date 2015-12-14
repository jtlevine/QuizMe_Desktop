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
    var set : QmSet?
    
    @IBOutlet weak var tvTable: NSTableView!
    @IBOutlet weak var btBack: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        getQuestions(set!.pid)
    }
    
    /**
     GetQuestions
     Requests all questions from server associated with logged in user.
     Stores them in questions array
     **/
    func getQuestions(id:Int){
        questions.removeAll()
        let send_this = "packID=\(id)"
        let request = getRequest(send_this, urlString: GET_QUESTIONS_FROM_SET_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in  //all this happens once request has been completed, in another queue
            if error != nil{
                print("Error with getting questions")
                return
            }
            if let data = data{
                do{
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSArray{    //put response into JSON so can access like a dictionary
                        dispatch_async(dispatch_get_main_queue(), {
                            for dic in json{
                                if case let qid as String = dic["qid"]{
                                    if case let q as String = dic["question_text"]{
                                        if case let a as String = dic["answer_text"]{
                                            let question = Question(qid: Int(qid)!, qText: q, aText: a, choices: nil)
                                            self.questions.append(question)
                                        }
                                    }
                                }
                            }
                            self.tvTable.reloadData()
                        })
                    }
                }
                catch _ as NSError {}
            }
        }
        task.resume()
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return questions.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        cell.textField!.stringValue = "Q:      " + questions[row].qText
        return cell
    }
    
    @IBAction func tvTable_onDoubleClick(sender: NSTableView) {
        let index = tvTable.selectedRow
        if(index >= 0){
                print("question number ", index, "clicked")
                let vc : SelectedCellVC = (self.storyboard?.instantiateControllerWithIdentifier("SelectedCell"))! as! SelectedCellVC
                vc.question = questions[index]
                vc.inSet = BoolWrapper(val: true)
                vc.set = set
                self.view.window?.contentViewController = vc
        }
    }
    @IBAction func btBack_onClick(sender: NSButton) {
        let vc : NSViewController = (self.storyboard?.instantiateControllerWithIdentifier("Recents"))! as! NSViewController
        self.view.window?.contentViewController = vc
    }
}
