//
//  RecentsVC.swift
//  QuizMe
//
//  Created by Josh Levine on 12/6/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class RecentsVC: NSViewController {
    
    var fetched = false     //if have fetched questions from server
    var sets = [QmSet]()
    var questions = [Question]()    //array of questions from server
    var scheduledForPush = [BoolWrapper]()   //parallel array with questions indicating if scheduled
    var qidsScheduledForPush = [Int]()  //qids of questions scheduled for push notifications
    @IBOutlet weak var scTypeDisplayed: NSSegmentedControl!
    @IBOutlet weak var tvTable: NSTableView!
    @IBOutlet weak var delete: NSButton!
    @IBOutlet weak var create: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setFetched", name: "setFetchedKey", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowWillClose", name: "NSWindowWillCloseNotification", object: nil)
        if USERNAME == ""{
            /*
            Causes 2 warnings: "Presenting view controllers on detached view controllers is discouraged" and
            379ae97e0b0b7b98d3521
            2015-11-04 22:43:06.371 QuizMe[686:195977] Unbalanced calls to begin/end appearance transitions for <UITabBarController:
            */
            //performSegueWithIdentifier("logIn", sender: self)
        }
    }
    
    func windowWillClose(){
        getQuestions()
        getSets()
    }
    
    func isScheduled(qid:Int) -> Bool{
        let limit = qidsScheduledForPush.count
        var i = 0
        while i < limit{
            if qid == qidsScheduledForPush[i]{
                return true
            }
            /*if qid < qidsScheduledForPush[i]{//array is sorted, so if array[i] > qid then qid not in list
            return false
            }*/
            i++
        }
        return false
    }
    
    /**
     ConfigureScheduleForPush
     Sets up parallel boolean array scheduledForPush
     **/
    func configureScheduleForPush(){
        for(var i = 0; i < questions.count;i++){
            if isScheduled(questions[i].qid) == true{
                scheduledForPush[i] = BoolWrapper(val: true)
            }else{
                scheduledForPush[i] = BoolWrapper(val: false)
            }
        }
    }

    /**
     When user logs out via Settings, this fires to reset fetched to false
     **/
    func setFetched(){
        fetched = false
    }
    override func viewWillAppear() {
        if USERNAME != "" {
            if fetched == false{
                getQuestions()
                getSets()
                fetched = true
                return
            }
            tvTable.reloadData() //always reload the tableview
        }
    }
    
    /**
     GetScheduledQuestions
     Requests qids of all scheduled questions for this device and stores them
     in qidsScheduledForPush
     **/
    func getScheduledQuestions(){
        let send_this = "device='\(DEVICE_TOKEN)'"
        let request = getRequest(send_this, urlString: GET_REGISTERED_QUESTIONS_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in  //all this happens once request has been completed, in another queue
            if error != nil{
                print("Error with creating login")
                return
            }
            if let data = data{
                do{
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSArray{    //put response into JSON so can access like a dictionary
                        dispatch_async(dispatch_get_main_queue(), {
                            for dic in json{
                                if case let qid as String = dic["qid"]{
                                    self.qidsScheduledForPush.append(Int(qid)!)
                                }
                            }
                            self.configureScheduleForPush()
                        })
                    }
                }
                catch _ as NSError {}
            }
        }
        task.resume()
    }

    /**
     GetQuestions
     Requests all questions from server associated with logged in user.
     Stores them in questions array
     **/
    func getQuestions(){
        if(UID == 0){
            return
        }
        questions.removeAll()
        qidsScheduledForPush.removeAll()
        scheduledForPush.removeAll()
        let send_this = "uid=\(UID)"
        let request = getRequest(send_this, urlString: GET_QUESTIONS_PHP)
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
                                            self.scheduledForPush.append(BoolWrapper(val:false))
                                        }
                                    }
                                }
                            }
                            self.tvTable.reloadData()
                            self.getScheduledQuestions()
                        })
                    }
                }
                catch _ as NSError {}
            }
        }
        task.resume()
    }
    
    /**
     DeleteQuestion
     Deletes question from server
     **/
    func deleteQuestion(qid:Int,index:Int){
        let send_this = "qid=\(qid)"
        let request = getRequest(send_this, urlString: DELETE_QUESTION_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in
            if error != nil{
                print("Error with order request")
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.questions.removeAtIndex(index)
                self.tvTable.reloadData()
            })
            
        }
        task.resume()
    }
    
    /**
     DeleteSet
     Deletes set from server
     **/
    func deleteSet(pid:Int,index:Int){
        let send_this = "pid=\(pid)"
        let request = getRequest(send_this, urlString: DELETE_SET_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in
            if error != nil{
                //alertUser()
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.sets.removeAtIndex(index)
                self.tvTable.reloadData()
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
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSArray{    //put response into JSON so can access like a dictionary
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
                        self.tvTable.reloadData()
                    })                }
                catch _ as NSError {}
            }
        }
        task.resume()
    }
    
    // MARK: - Table view data source
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        if scTypeDisplayed.selectedSegment == 0{
            return questions.count
        }
        else{
            return sets.count
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        if scTypeDisplayed.selectedSegment == 0{ //if questions selected
            cell.textField!.stringValue = "Q:      " + questions[row].qText
        }
        else{
            cell.textField!.stringValue = "Set:      " + sets[row].name
        }
        return cell
    }
    
    @IBAction func scTypeDisplayed_valueChanged(sender: NSSegmentedControl) {
        tvTable.reloadData()
    }
    
    @IBAction func delete_clicked(sender: NSButton) {
        let index = tvTable.selectedRow
        if(scTypeDisplayed.selectedSegment == 0){
            if(index >= 0){
                deleteQuestion(questions[index].qid,index: index)
            }
        }
        else{
            if(index >= 0){
                deleteSet(sets[index].pid,index: index)
            }
        }
    }
    
}
