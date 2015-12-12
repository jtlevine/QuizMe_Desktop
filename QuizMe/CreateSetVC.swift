//
//  CreateSetVC.swift
//  QuizMe
//
//  Created by Josh Levine on 12/11/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class CreateSetVC: NSViewController {

    @IBOutlet weak var btCancel: NSButton!
    @IBOutlet weak var btCreate: NSButton!
    @IBOutlet weak var tfSetName: NSTextField!
    @IBOutlet weak var pvTopic: NSPopUpButton!
    @IBOutlet weak var swchPrivate: NSButton!
    
    let topics = ["None", "Biology","Chemistry","Computer Science", "Entertainment", "Earth Science", "Geography", "History", "Language","Literature","Miscellaneous", "Physics", "Sports"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pvTopic.removeAllItems()
        pvTopic.addItemsWithTitles(topics)
    }
    
    func createSet(){
        var priv : Int
        if (swchPrivate.state == 1){
            print("private")
            priv = 1
        }else{
            priv = 0
            print("not private")
        }
        let topicName = topics[pvTopic.indexOfSelectedItem]
        let send_this = "uid=\(UID)&name='\(tfSetName.stringValue)'&topic='\(topicName)'&private=\(priv)"
        let request = getRequest(send_this, urlString: CREATE_SET_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in  //all this happens once request has been completed, in another queue
            if error != nil{
                print("Error with creating login")
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                alertUser("Set created")
                NSNotificationCenter.defaultCenter().postNotificationName("refetchSetsKey", object: self)
                self.view.window?.performClose(self)
            })
            
        }
        task.resume()
    }
    @IBAction func btCreate_onClick(sender: NSButton) {
        createSet()
    }
    
    @IBAction func btCancel_onClick(sender: NSButton) {
        self.view.window?.performClose(self)
    }
}
