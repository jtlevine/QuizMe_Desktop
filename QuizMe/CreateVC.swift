//
//  CreateVC.swift
//  QuizMe
//
//  Created by Josh Levine on 12/8/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class CreateVC: NSViewController {

    var fetched = false
    var state = "q"
    var question = Question()
    var sets = [QmSet]()
    var pickedSet : QmSet?
    @IBOutlet weak var btCreateNewSet: NSButton!
    @IBOutlet weak var lbLabel: NSTextField!
    @IBOutlet weak var pvSet: NSPopUpButton!
    @IBOutlet weak var tvTextView: NSTextField!
    @IBOutlet weak var btEnter: NSButton!
    @IBOutlet weak var btGoBack: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reFetchSets", name: "refetchSetsKey", object: nil)
    }
    override func viewWillAppear() {
        if fetched == false{
            getSets()
            fetched = true
        }
    }
    
    func reFetchSets(){
        getSets()
    }
    
    func inputGood() -> Bool{
        if tvTextView.stringValue.characters.count < 200                                                                                                                                                                                                       && tvTextView.stringValue.characters.count > 0 {
            return true
        }
        return false
    }
    
    /**
     ChangeState
     Updates user prompt for either question or answer
     **/
    func changeState(){
        if state == "q"{
            question.qText = tvTextView.stringValue
            lbLabel.stringValue = "Enter Answer:"
            tvTextView.stringValue = ""
            state = "a"
            btGoBack.hidden = false
            
        }
        else{//state == "a"
            question.aText = tvTextView.stringValue
            lbLabel.stringValue = "Enter Question:"
            tvTextView.stringValue = ""
            state = "q"
            submitQuestion()
            btGoBack.hidden = true
        }
    }
    
    //MARK: - Database interaction
    /**
    SubmitQuestion
    creates question in db
    /***SINGLE QUOTES INCLUDED IN Q.TEXT OR A.TEXT WILL MAKE REQUEST FAIL**/
    **/
    func submitQuestion(){
        let qText = formatStringRemoveQuotes(question.qText)
        let pid = sets[pvSet.indexOfSelectedItem].pid
        let send_this = "question='\(qText)'&answer='\(question.aText)'&uid=\(UID)&setID=\(pid)"
        let request = getRequest(send_this, urlString: CREATE_QUESTION_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in  //all this happens once request has been completed, in another queue
            if error != nil{
                print("Error with creating login")
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                alertUser("Question created!")
                NSNotificationCenter.defaultCenter().postNotificationName("setFetchedKey", object: self)
                self.view.window?.performClose(self)
            })
        }
        task.resume()
    }
    
    /**
     GetSets
     Fetches user defined sets from server
     **/
    func getSets(){
        sets.removeAll()
        sets.append(QmSet(pid: 0, name: "NONE", topic: "", privat: "1", cr: 0))//always have 'NONE' as the first option
        let send_this = "uid=\(UID)"
        let request = getRequest(send_this, urlString: GET_SETS_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in  //all this happens once request has been completed, in another queue
            if error != nil{
                print("Error with creating login")
                return
            }
            if let data = data{
                do{
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.MutableContainers,NSJSONReadingOptions.AllowFragments]) as? NSArray{
                        for dic in json{
                            if case let id as String = dic["pid"]{
                                if case let pname as String = dic["name"]{
                                    if case let topic as String = dic["topic"]{
                                        if case let priv as String = dic["private"]{
                                            let temp = QmSet(pid: Int(id)!, name: pname, topic: topic, privat: priv,cr:UID)
                                            self.sets.append(temp)
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.reload_pvSet()
                    })
                }
                catch let e as NSError {
                    print(e)
                }
            }
        }
        task.resume()
    }
    
    func reload_pvSet(){
        pvSet.removeAllItems()
        var strs : [String] = []
        for i in sets
        {
            strs.append(i.name)
        }
        pvSet.addItemsWithTitles(strs)
    }
    
    @IBAction func btCreate_onClick(sender: NSButton) {
        if(!inputGood()){
            //display error
            return
        }
        changeState()
    }
    
    @IBAction func btGoBack_onClick(sender: NSButton) {
        state = "q"
        lbLabel.stringValue = "Enter Question:"
        tvTextView.stringValue = question.qText
        tvTextView.becomeFirstResponder()
        btGoBack.hidden = true
    }
    
    @IBAction func btCreateNewSet_onClick(sender: NSButton) {
    }
    
}
