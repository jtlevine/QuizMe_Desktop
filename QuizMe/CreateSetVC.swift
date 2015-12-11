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
    
    let topics = ["None", "Biology","Chemistry","Computer Science", "Entertainment", "Earth Science", "Geography", "History", "Language","Literature","Miscellaneous", "Physics", "Sports"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pvTopic.addItemsWithTitles(topics)
    }
    
    /*func createSet(){
        var priv : Int
        if swchPrivate.on{
            priv = 1
        }else{
            priv = 0
        }
        let topicName = topics[pvTopic.selectedRowInComponent(0)]
        let send_this = "uid=\(UID)&name='\(tfSetNme.text!)'&topic='\(topicName)'&private=\(priv)"
        let request = getRequest(send_this, urlString: CREATE_SET_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in  //all this happens once request has been completed, in another queue
            if error != nil{
                print("Error with creating login")
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                alertUser("Set created",you:self)
                NSNotificationCenter.defaultCenter().postNotificationName("refetchSetsKey", object: self)
                NSNotificationCenter.defaultCenter().postNotificationName(notification_key, object: self)
            })
            
        }
        task.resume()
    }*/
    
}
